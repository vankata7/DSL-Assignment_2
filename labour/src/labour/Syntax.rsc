module labour::Syntax

/*
 * Define a concrete syntax for LaBouR. The language's specification is available in the PDF (Section 2)
 */
/*
 * Note, the Server expects the language base to be called BoulderingWall.
 * You are free to change this name, but if you do so, make sure to change everywhere else to make sure the
 * plugin works accordingly.
 */

extend lang::std::Layout; // Handles whitespaces and comments automatically
extend lang::std::Id;

lexical HoldId = [0-9][0-9][0-9][0-9]; // Enforces the 4-digit rule 
lexical AlphanumId = [a-zA-Z0-9]+; // Enforces alphanumeric IDs 
lexical String = "\"" ![\"]* "\""; // Basic string matching

start syntax BoulderingWall 
  = "bouldering_wall" String name "{" 
      "routes" "[" {Route ","}* "]" "," 
      "volumes" "[" {Volume ","}* "]" 
    "}";

// Numbers
lexical Int = "-"? [0-9]+; // Allows negative numbers for depth
lexical Nat = [0-9]+;    // For angles, radius, etc.

// IDs
lexical HoldIdString = "\"" [0-9][0-9][0-9][0-9] "\""; 
lexical AlphanumericString = "\"" [a-zA-Z0-9\ ]+ "\""; // Includes spaces for names

// Colors
lexical Color 
  = "white" | "yellow" | "green" | "blue" | "red" 
  | "purple" | "pink" | "black" | "orange";

syntax Point 
  = "{" "x" ":" Int x "," "y" ":" Int y "}";

syntax AnglePoint
  = "{" "angle" ":" Nat angle "}";


syntax Hold = "hold" HoldIdString id "{" {HoldProp ","}* props "}";

syntax HoldProp
  = "pos" ":" Point
  | "pos" ":" AnglePoint
  | "colours" "[" {Color ","}+ "]"
  | "shape" ":" AlphanumericString
  | "rotation" ":" Nat
  | "start_hold" ":" Nat
  | "end_hold"
  ;

syntax Volume
  = "circle" "{" {CircleProp ","}* props "}"
  | "triangle" "{" {TriangleProp ","}* props "}"
  ;

syntax CircleProp
  = "pos" ":" Point
  | "depth" ":" Int
  | "radius" ":" Nat
  | "front_holds" "[" {Hold ","}* "]"
  | "side_holds" "[" {Hold ","}* "]"
  ;

syntax TriangleProp
  = "pos" ":" Point
  | "extrusion" ":" Point
  | "depth" ":" Int
  | "corners" "[" {Point ","}* "]"
  | "left_holds" "[" {Hold ","}* "]"
  | "right_holds" "[" {Hold ","}* "]"
  | "bottom_holds" "[" {Hold ","}* "]"
  ;

syntax Route = "bouldering_route" AlphanumericString id "{" {RouteProp ","}* props "}";

syntax RouteProp
  = "grade" ":" AlphanumericString
  | "grid_base_point" Point  // Note: listing 6 shows no colon after grid_base_point
  | "holds" "[" {RouteStep ","}* "]"
  ;

// A step in the route is either a single hold or a split
syntax RouteStep
  = HoldIdString singleHold
  | "{" HoldIdString splitA "," HoldIdString splitB "}"
  ;