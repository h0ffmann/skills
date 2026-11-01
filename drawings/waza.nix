# The skills drawing: 技 (waza, "skill"), brushed in its seven strokes, in the standard order.
#
# The left part is 扌, the hand: a horizontal, a vertical with a hook, and a rising stroke.
# The right part is 支, to branch: a horizontal and a vertical (十), then 又, a horizontal that
# turns and falls to the left, and a long stroke that falls to the right and spreads.
#
# Each stroke is a brush line through hand-placed points, with a brush width at each point.
# The stroke order follows KanjiVG. The points are drawn here by hand.
{ lib, pen }:
let
  # The seven strokes of 技, in writing order, in a 0-100 box: [x y brush width at that point].
  strokes = [
    # 1 ㇐ the short horizontal of 扌, stopped at the end
    [
      [ 9.0 35.0 5.6 ]
      [ 13.0 33.8 4.4 ]
      [ 26.0 32.4 3.2 ]
      [ 35.5 31.0 3.6 ]
      [ 38.5 32.0 5.0 ]
    ]
    # 2 ㇚ the vertical of 扌, down through the horizontal, with a hook to the left
    [
      [ 23.0 13.0 6.4 ]
      [ 23.8 19.0 5.4 ]
      [ 23.8 48.0 4.8 ]
      [ 23.6 76.0 4.8 ]
      [ 23.2 84.0 5.4 ]
      [ 21.6 85.6 4.6 ]
      [ 18.6 83.2 2.6 ]
      [ 15.6 80.4 0.8 ]
    ]
    # 3 ㇀ the rising stroke of 扌, from the lower left up to the right
    [
      [ 8.5 66.0 6.0 ]
      [ 13.0 63.8 4.8 ]
      [ 26.0 57.0 2.8 ]
      [ 39.0 50.0 0.8 ]
    ]
    # 4 ㇐ the long horizontal of 支
    [
      [ 45.0 31.0 6.0 ]
      [ 49.0 29.8 4.6 ]
      [ 70.0 28.4 3.2 ]
      [ 90.0 27.0 3.4 ]
      [ 95.5 28.4 5.6 ]
    ]
    # 5 ㇑ the short vertical of 支, through the horizontal, stopped
    [
      [ 69.0 11.0 6.2 ]
      [ 69.6 17.0 5.0 ]
      [ 69.6 34.0 4.4 ]
      [ 69.4 45.0 5.2 ]
    ]
    # 6 ㇇ the horizontal of 又, which turns and falls to the lower left
    [
      [ 50.0 52.0 5.6 ]
      [ 54.0 50.8 4.2 ]
      [ 72.0 49.6 3.2 ]
      [ 84.0 48.8 4.6 ]
      [ 86.0 51.0 4.8 ]
      [ 80.0 62.0 4.0 ]
      [ 68.0 76.0 3.2 ]
      [ 56.0 86.0 2.0 ]
      [ 44.5 92.5 0.8 ]
    ]
    # 7 ㇏ the falling stroke of 又, to the lower right, spread at the foot and swept out
    [
      [ 57.0 60.0 2.4 ]
      [ 63.0 67.0 3.4 ]
      [ 72.0 77.0 4.6 ]
      [ 82.0 85.6 6.2 ]
      [ 90.0 89.4 6.6 ]
      [ 97.5 90.6 1.0 ]
    ]
  ];

  # The canvas, square, with the kanji in its middle: the 0-100 box scaled by `scale` about its
  # point (53, 52). The widths of `strokes` are times `weight`, how heavy the brush is.
  side = 240.0;
  scale = 2.25;
  weight = 1.9;
  place = p: [
    (pen.fma (builtins.elemAt p 0 - 53.0) scale (side / 2.0))
    (pen.fma (builtins.elemAt p 1 - 52.0) scale (side / 2.0))
  ];
in
{
  inherit strokes;

  drawing = pen.drawing {
    w = side;
    h = side;
    label = "技 (waza, skill) brushed in its seven strokes, by @h0ffmann";
    desc = "Drawn from the Desmos expressions of waza.desmos.json: cubic Béziers through hand-placed points, each piece at its brush width.";
    marks = lib.concatMap
      (s: pen.brush (map place s) (map (p: builtins.elemAt p 2 * weight) s))
      strokes;
  };
}
