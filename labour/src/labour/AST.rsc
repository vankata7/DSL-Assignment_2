module labour::AST

/*
 * Define the Abstract Syntax for LaBouR
 * - Hint: make sure there is an almost one-to-one correspondence with the grammar in Syntax.rsc
 */

// --- 1. Shared Data (Must come first) ---

data Point(loc src=|unknown:///|)
  = point(int x, int y)
  ;
  
// --- 2. Holds ---

data HoldProp(loc src=|unknown:///|)
  = holdPos(Point p)
  | holdAngle(int angle)
  | holdColours(list[str] colours)
  | holdShape(str shape)
  | holdRotation(int rotation)
  | startHold(int arg)
  | endHold()
  ;

data Hold(loc src=|unknown:///|)
  = hold(str id, list[HoldProp] props)
  ;

// --- 3. Routes ---

data RouteStep(loc src=|unknown:///|)
  = singleHold(str id)
  | splitHolds(str splitA, str splitB)
  ;

data RouteProp(loc src=|unknown:///|)
  = grade(str grade)
  | gridBasePoint(Point p)
  | routeHolds(list[RouteStep] steps)
  ;

data Route(loc src=|unknown:///|)
  = route(str id, list[RouteProp] props)
  ;

// --- 4. Volumes ---

data CircleProp(loc src=|unknown:///|)
  = circlePos(Point p)
  | circleDepth(int d)
  | circleRadius(int r)
  | circleFrontHolds(list[Hold] holds)
  | circleSideHolds(list[Hold] holds)
  ;

data TriangleProp(loc src=|unknown:///|)
  = trianglePos(Point p)
  | triangleExtrusion(Point p)
  | triangleDepth(int d)
  | triangleCorners(list[Point] corners)
  | triangleLeftHolds(list[Hold] holds)
  | triangleRightHolds(list[Hold] holds)
  | triangleBottomHolds(list[Hold] holds)
  ;

data Volume(loc src=|unknown:///|)
  = circle(list[CircleProp] props)
  | triangle(list[TriangleProp] props)
  ;

// --- 5. Main Wall (Uses everything defined above) ---

data BoulderingWall(loc src=|unknown:///|)
  = wall(str name, list[Route] routes, list[Volume] volumes)
  ;