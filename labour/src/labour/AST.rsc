module labour::AST

/*
 * Define the Abstract Syntax for LaBouR
 * - Hint: make sure there is an almost one-to-one correspondence with the grammar in Syntax.rsc
 */

// --- 1. Shared Data ---
data PointAst(loc src=|unknown:///|)
  = point(int x, int y)
  ;

// --- 2. Holds ---
data HoldPropAst(loc src=|unknown:///|)
  = holdPos(PointAst p)
  | holdAngle(int angle)
  | holdColours(list[str] colours)
  | holdShape(str shape)
  | holdRotation(int rotation)
  | startHold(int arg)
  | endHold()
  ;

data HoldAst(loc src=|unknown:///|)
  = hold(str id, list[HoldPropAst] props)
  ;

// --- 3. Routes ---
data RouteStepAst(loc src=|unknown:///|)
  = singleHold(str id)
  | splitHolds(str splitA, str splitB)
  ;

data RoutePropAst(loc src=|unknown:///|)
  = grade(str grade)
  | gridBasePoint(PointAst p)
  | routeHolds(list[RouteStepAst] steps)
  ;

data RouteAst(loc src=|unknown:///|)
  = route(str id, list[RoutePropAst] props)
  ;

// --- 4. Volumes ---
data CirclePropAst(loc src=|unknown:///|)
  = circlePos(PointAst p)
  | circleDepth(int d)
  | circleRadius(int r)
  | circleFrontHolds(list[HoldAst] holds)
  | circleSideHolds(list[HoldAst] holds)
  ;

data TrianglePropAst(loc src=|unknown:///|)
  = trianglePos(PointAst p)
  | triangleExtrusion(PointAst p)
  | triangleDepth(int d)
  | triangleCorners(list[PointAst] corners)
  | triangleLeftHolds(list[HoldAst] holds)
  | triangleRightHolds(list[HoldAst] holds)
  | triangleBottomHolds(list[HoldAst] holds)
  ;

data VolumeAst(loc src=|unknown:///|)
  = circle(list[CirclePropAst] circleProps)
  | triangle(list[TrianglePropAst] triangleProps)
  ;

// --- 5. Main Wall ---
data BoulderingWallAst(loc src=|unknown:///|)
  = wall(str name, list[RouteAst] routes, list[VolumeAst] volumes)
  ;