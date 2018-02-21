static class Config {
  static final int y_margin_top = 100;
  static final int y_margin_bottom = 40;
  static final int axis_label_y = 10;
  static final int x_margin = 40; // on each side
  static final int axis_width = 15; // width of each y axis (in pixels)
  static final int col_label_y = 20;
  
  static final color axis_color = #FFFFFF;
  static final color axis_highlight = #bdbdbd;
  static final color axis_range_color = #FF0000;
  
  // scale for coloring the lines (use lerpColor)
  //static final color min_color = #bdd7e7;
  //static final color max_color = #08519c;
  static final color min_color = #c6dbef;
  static final color max_color = #08306b;
  
  static final color button_text_color = #000000;
  static final color button_fill_color = #FFFFFF;
  static final float button_corner_rounding = 4.0;
  
  static final float hover_buffer = 2; // how close to the line (in y axis) to be to count as hover
  
  static final int normal_weight = 1;
  static final int highlighted_weight = 4;
}