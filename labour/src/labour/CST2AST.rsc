module labour::CST2AST

import IO;
import Prelude;
import String;

import labour::AST;
import labour::Syntax;

/*
 * Implement a mapping from concrete syntax trees (CSTs) to abstract syntax trees (ASTs)
 * Hint: Use switch to do case distinction with concrete patterns
 * Map regular CST arguments (e.g., *, +, ?) to lists
 * Map lexical nodes to Rascal primitive types (bool, int, str)
 */

// --- Helper Functions ---

// Removes the surrounding quotes from strings and IDs
str stripQuotes(str s) = substring(s, 1, size(s) - 1);

// --- Entry Point ---

BoulderingWall cst2ast(start[BoulderingWall] W) = cst2ast(W.top);

// --- Main Wall ---

BoulderingWall cst2ast(BoulderingWall W) {
  switch (W) {
    case (BoulderingWall)`bouldering_wall <String name> { routes [ <{Route ","}* rts> ] volumes [ <{Volume ","}* vols> ] }`:
      return wall(stripQuotes("<name>"), [cst2ast(r) | r <- rts], [cst2ast(v) | v <- vols], src=W@\loc);
    default: throw "Unhandled BoulderingWall: <W>";
  }
}

// --- Shared Data ---

Point cst2ast(Point P) {
  switch (P) {
    case (Point)`{ x : <Int x> , y : <Int y> }`:
      return point(toInt("<x>"), toInt("<y>"), src=P@\loc);
    default: throw "Unhandled Point: <P>";
  }
}

// --- Holds ---

Hold cst2ast(Hold H) {
  switch (H) {
    case (Hold)`hold <HoldIdString id> { <{HoldProp ","}* props> }`:
      return hold(stripQuotes("<id>"), [cst2ast(p) | p <- props], src=H@\loc);
    default: throw "Unhandled Hold: <H>";
  }
}

HoldProp cst2ast(HoldProp HP) {
  switch (HP) {
    case (HoldProp)`pos : <Point p>`: return holdPos(cst2ast(p), src=HP@\loc);
    case (HoldProp)`pos : { angle : <Nat a> }`: return holdAngle(toInt("<a>"), src=HP@\loc);
    case (HoldProp)`colours [ <{Color ","}+ cols> ]`: return holdColours(["<c>" | c <- cols], src=HP@\loc);
    case (HoldProp)`shape : <AlphanumericString s>`: return holdShape(stripQuotes("<s>"), src=HP@\loc);
    case (HoldProp)`rotation : <Nat n>`: return holdRotation(toInt("<n>"), src=HP@\loc);
    case (HoldProp)`start_hold : <Nat n>`: return startHold(toInt("<n>"), src=HP@\loc);
    case (HoldProp)`end_hold`: return endHold(src=HP@\loc);
    default: throw "Unhandled HoldProp: <HP>";
  }
}

// --- Routes ---

Route cst2ast(Route R) {
  switch (R) {
    case (Route)`bouldering_route <AlphanumericString id> { <{RouteProp ","}* props> }`:
      return route(stripQuotes("<id>"), [cst2ast(p) | p <- props], src=R@\loc);
    default: throw "Unhandled Route: <R>";
  }
}

RouteProp cst2ast(RouteProp RP) {
  switch (RP) {
    case (RouteProp)`grade : <AlphanumericString g>`: return grade(stripQuotes("<g>"), src=RP@\loc);
    case (RouteProp)`grid_base_point <Point p>`: return gridBasePoint(cst2ast(p), src=RP@\loc);
    case (RouteProp)`holds [ <{RouteStep ","}* steps> ]`: return routeHolds([cst2ast(s) | s <- steps], src=RP@\loc);
    default: throw "Unhandled RouteProp: <RP>";
  }
}

RouteStep cst2ast(RouteStep RS) {
  switch (RS) {
    case (RouteStep)`<HoldIdString id>`: 
      return singleHold(stripQuotes("<id>"), src=RS@\loc);
    case (RouteStep)`{ <HoldIdString id1> , <HoldIdString id2> }`: 
      return splitHolds(stripQuotes("<id1>"), stripQuotes("<id2>"), src=RS@\loc);
    default: throw "Unhandled RouteStep: <RS>";
  }
}

// --- Volumes ---

Volume cst2ast(Volume V) {
  switch (V) {
    case (Volume)`circle { <{CircleProp ","}* props> }`:
      return circle([cst2ast(p) | p <- props], src=V@\loc);
    case (Volume)`triangle { <{TriangleProp ","}* props> }`:
      return triangle([cst2ast(p) | p <- props], src=V@\loc);
    default: throw "Unhandled Volume: <V>";
  }
}

CircleProp cst2ast(CircleProp CP) {
  switch (CP) {
    case (CircleProp)`pos : <Point p>`: return circlePos(cst2ast(p), src=CP@\loc);
    case (CircleProp)`depth : <Int d>`: return circleDepth(toInt("<d>"), src=CP@\loc);
    case (CircleProp)`radius : <Nat r>`: return circleRadius(toInt("<r>"), src=CP@\loc);
    case (CircleProp)`front_holds [ <{Hold ","}* holds> ]`: return circleFrontHolds([cst2ast(h) | h <- holds], src=CP@\loc);
    case (CircleProp)`side_holds [ <{Hold ","}* holds> ]`: return circleSideHolds([cst2ast(h) | h <- holds], src=CP@\loc);
    default: throw "Unhandled CircleProp: <CP>";
  }
}

TriangleProp cst2ast(TriangleProp TP) {
  switch (TP) {
    case (TriangleProp)`pos : <Point p>`: return trianglePos(cst2ast(p), src=TP@\loc);
    case (TriangleProp)`extrusion : <Point p>`: return triangleExtrusion(cst2ast(p), src=TP@\loc);
    case (TriangleProp)`depth : <Int d>`: return triangleDepth(toInt("<d>"), src=TP@\loc);
    case (TriangleProp)`corners [ <{Point ","}* corners> ]`: return triangleCorners([cst2ast(c) | c <- corners], src=TP@\loc);
    case (TriangleProp)`left_holds [ <{Hold ","}* holds> ]`: return triangleLeftHolds([cst2ast(h) | h <- holds], src=TP@\loc);
    case (TriangleProp)`right_holds [ <{Hold ","}* holds> ]`: return triangleRightHolds([cst2ast(h) | h <- holds], src=TP@\loc);
    case (TriangleProp)`bottom_holds [ <{Hold ","}* holds> ]`: return triangleBottomHolds([cst2ast(h) | h <- holds], src=TP@\loc);
    default: throw "Unhandled TriangleProp: <TP>";
  }
}