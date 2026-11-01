# The README drawing, 技, in pure Nix. `svg`, `desmos` and `checkSvg` are the text of the files.
# `failures` is the list of the tests that failed (lib.runTests). It is empty when all pass.
{ lib }:
let
  pen = import ./pen.nix { inherit lib; };
  waza = import ./waza.nix { inherit lib pen; };
  near = a: b: (if a < b then b - a else a - b) < 1.0e-9;
  bz = [ [ 0.0 0.0 ] [ 10.0 30.0 ] [ 40.0 (-10.0) ] [ 50.0 20.0 ] ];
  inherit (builtins) elemAt length;
  first = s: elemAt s 0;
  last = s: elemAt s (length s - 1);
  stroke = elemAt waza.strokes;
  col = k: p: elemAt p k;
  maxOf = k: s: lib.foldl' lib.max 0.0 (map (col k) s);
in
{
  inherit (waza.drawing) svg desmos checkSvg;

  failures = lib.runTests {
    testNumbersAreShort = {
      expr = map pen.num [ 12.0 (-3.5) 0.1234 (-0.0001) ];
      expected = [ "12" "-3.5" "0.123" "0" ];
    };
    testAPolynomialReadsBack = {
      expr = let s = pen.poly [ 12.5 (-3.0) 0.0 0.25 ]; in [ s (pen.parsePoly s) ];
      expected = [ "12.5-3t+0.25t^{3}" [ 12.5 (-3.0) 0.0 0.25 ] ];
    };
    testThePowerFormIsTheBezier = {
      # The midpoint of a cubic Bézier is (p0 + 3p1 + 3p2 + p3) / 8.
      expr = let cx = elemAt (pen.coeffs bz) 0; in
        near (pen.evalPoly cx 0.5) 25.0 && near (pen.evalPoly cx 1.0) 50.0;
      expected = true;
    };
    testWazaHasItsSevenStrokesInOrder = {
      expr = [
        (length waza.strokes)
        # 扌 is on the left of 支: strokes 1 to 3 end before stroke 4 starts
        (builtins.all (k: maxOf 0 (stroke k) < col 0 (first (stroke 3)) + 1.0) [ 0 1 2 ])
        # the vertical of 扌 crosses its horizontal and ends in a hook to the left
        (col 1 (first (stroke 1)) < col 1 (first (stroke 0)) && maxOf 1 (stroke 1) > col 1 (first (stroke 2)))
        (col 0 (last (stroke 1)) < col 0 (first (stroke 1)))
        # the rising stroke goes up to the right
        (col 0 (last (stroke 2)) > col 0 (first (stroke 2)) && col 1 (last (stroke 2)) < col 1 (first (stroke 2)))
        # the vertical of 十 crosses the long horizontal
        (col 1 (first (stroke 4)) < col 1 (first (stroke 3)) && col 1 (last (stroke 4)) > col 1 (first (stroke 3)))
        # 又: the turned stroke ends low on the left, the last stroke ends low on the right
        (col 0 (last (stroke 5)) < col 0 (first (stroke 5)) && col 1 (last (stroke 5)) > 85.0)
        (col 0 (last (stroke 6)) > col 0 (first (stroke 6)) && col 1 (last (stroke 6)) > 85.0)
      ];
      expected = [ 7 true true true true true true true ];
    };
    # Each Desmos expression, read back from its LaTeX, stays within 0.01 of its line.
    testTheDesmosFileIsTheDrawing = {
      expr = waza.drawing.worstSquared < 0.01 * 0.01;
      expected = true;
    };
  };
}
