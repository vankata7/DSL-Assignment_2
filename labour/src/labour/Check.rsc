module labour::Check

import labour::AST;
import labour::Parser;
import labour::CST2AST;

import IO;
import List;
import Set;
import Prelude;
import String;


/*
 * Implement a well-formedness checker for the LaBouR language. For this you must use the AST.
 * - Hint: Map regular CST arguments (e.g., *, +, ?) to lists
 * - Hint: Map lexical nodes to Rascal primitive types (bool, int, str)
 * - Hint: Use switch to do case distinction with concrete patterns
 */

/*
 * Define a function per each verification defined in the PDF (Section 2.2.)
 * Some examples are provided below.
 */


// A helper to extract all Hold nodes from the wall
list[HoldAst] getAllHolds(BoulderingWallAst wall) {
  list[HoldAst] allHolds = [];
  for (v <- wall.volumes) {
    switch (v) {
      case circle(props):
        for (p <- props) {
          if (circleFrontHolds(hs) := p) allHolds += hs;
          if (circleSideHolds(hs) := p) allHolds += hs;
        }
      case triangle(props):
        for (p <- props) {
          if (triangleLeftHolds(hs) := p) allHolds += hs;
          if (triangleRightHolds(hs) := p) allHolds += hs;
          if (triangleBottomHolds(hs) := p) allHolds += hs;
        }
    }
  }
  return allHolds;
}

// 2. A helper to get a specific hold by its ID
HoldAst getHoldById(BoulderingWallAst wall, str id) {
  for (h <- getAllHolds(wall)) {
    if (h.id == id) return h;
  }
  throw "Hold ID <id> not found in any volume!";
}

// 3. A helper to extract all hold IDs referenced in a Route
list[str] getRouteHoldIds(RouteAst r) {
  list[str] ids = [];
  for (p <- r.props) {
    if (routeHolds(steps) := p) {
      for (step <- steps) {
        switch (step) {
          case singleHold(id): ids += id;
          case splitHolds(idA, idB): { ids += idA; ids += idB; }
        }
      }
    }
  }
  return ids;
}

set[str] getHoldColoursSet(HoldAst h) {
  for (p <- h.props) {
    if (holdColours(cols) := p) return toSet(cols);
  }
  return {};
}

bool checkBoulderWallConfiguration(BoulderingWallAst wall){
  bool hasRequiredNodes = size(wall.routes) > 0 && size(wall.volumes) > 0;
  
  bool holdsCount      = checkNumberOfHolds(wall);
  bool startHoldLimit  = checkStartingHoldsTotalLimit(wall);
  bool uniqueEndHold   = checkUniqueEndHold(wall);
  bool maxOneSplit     = checkMaxOneSplit(wall);
  bool colorMatch      = checkRouteColours(wall);
  bool propBounds      = checkHoldProperties(wall);

  return (hasRequiredNodes && holdsCount && startHoldLimit && uniqueEndHold && maxOneSplit && colorMatch && propBounds);
}


// Check that there are at least two holds in the wall
bool checkNumberOfHolds(BoulderingWallAst wall) {
  for (r <- wall.routes) {
    if (size(getRouteHoldIds(r)) < 2) {
      println("Validation Failed: Route <r.id> has less than 2 holds.");
      return false;
    }
  }
  return true;
}

// Check that routes have between zero and two hand start holds
bool checkStartingHoldsTotalLimit(BoulderingWallAst wall) {
  for (r <- wall.routes) {
    int startCount = 0;
    list[str] routeIds = getRouteHoldIds(r);
    
    for (id <- routeIds) {
      HoldAst h = getHoldById(wall, id);
      for (prop <- h.props) {
        if (startHold(_) := prop) startCount += 1;
      }
    }
    
    if (startCount > 2) {
      println("Validation Failed: Route <r.id> has <startCount> start holds (max 2).");
      return false;
    }
  }
  return true;
}

// Rule 4 & 8: At most one split initiation per route (prevents split-after-merge violations)
bool checkMaxOneSplit(BoulderingWallAst wall) {
  for (r <- wall.routes) {
    int splitsStarted = 0;
    bool currentlyInSplit = false;
    
    for (p <- r.props) {
      if (routeHolds(steps) := p) {
        for (step <- steps) {
          switch (step) {
            case singleHold(_): {
              // We are back to a single hold (merged)
              currentlyInSplit = false;
            }
            case splitHolds(_, _): {
              // If we weren't already in a split, this is a new split starting!
              if (!currentlyInSplit) {
                splitsStarted += 1;
                currentlyInSplit = true;
              }
            }
          }
        }
      }
    }
    
    if (splitsStarted > 1) {
      println("Validation Failed: Route <r.id> starts a split more than once (violates Rule 4/8).");
      return false;
    }
  }
  return true;
}

// This function will insure that there is only one hold assign to end hold
bool checkUniqueEndHold(BoulderingWallAst wall){
  for (r <- wall.routes) {
    int endCount = 0;
    bool hasSplit = false;
    
    for (p <- r.props) {
      if (routeHolds(steps) := p) {
        for (step <- steps) {
          if (splitHolds(_, _) := step) hasSplit = true;
        }
      }
    }

    list[str] routeIds = getRouteHoldIds(r);
    for (id <- routeIds) {
      HoldAst h = getHoldById(wall, id);
      for (prop <- h.props) {
        if (endHold() := prop) endCount += 1;
      }
    }

    if (!hasSplit && endCount > 1) {
      println("Validation Failed: Route <r.id> does not split but has <endCount> end holds (max 1).");
      return false;
    }
    if (hasSplit && endCount > 2) {
      println("Validation Failed: Route <r.id> splits but has <endCount> end holds (max 2).");
      return false;
    }
  }
  return true;
}

bool checkRouteColours(BoulderingWallAst wall) {
  for (r <- wall.routes) {
    list[str] routeIds = getRouteHoldIds(r);
    if (size(routeIds) == 0) continue;

    HoldAst firstHold = getHoldById(wall, routeIds[0]);
    set[str] sharedColours = getHoldColoursSet(firstHold);

    for (id <- routeIds) {
      HoldAst h = getHoldById(wall, id);
      sharedColours = sharedColours & getHoldColoursSet(h);
    }

    if (size(sharedColours) == 0) {
      println("Validation Failed: Holds in Route <r.id> do not share a common colour.");
      return false;
    }
  }
  return true;
}

// Rules 12, 13, 14: Ensure bounds for angles (0-359) and mandatory properties
bool checkHoldProperties(BoulderingWallAst wall) {
  for (h <- getAllHolds(wall)) {
    bool hasPos = false;
    bool hasShape = false;
    bool hasColours = false;

    for (p <- h.props) {
      if (holdPos(_) := p) hasPos = true;
      if (holdAngle(a) := p) {
        hasPos = true;
        if (a < 0 || a > 359) {
          println("Validation Failed: Hold <h.id> angle <a> is out of bounds (0-359).");
          return false;
        }
      }
      if (holdShape(_) := p) hasShape = true;
      if (holdColours(_) := p) hasColours = true;
      
      if (holdRotation(rot) := p) {
         if (rot < 0 || rot > 359) {
            println("Validation Failed: Hold <h.id> rotation <rot> is out of bounds (0-359).");
            return false;
         }
      }
    }

    if (!hasPos || !hasShape || !hasColours) {
      println("Validation Failed: Hold <h.id> is missing pos, shape, or colours.");
      return false;
    }
  }
  return true;
}