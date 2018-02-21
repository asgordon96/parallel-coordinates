// class for the main parallel coordinates representation
class ParallelCoordinates {
  Data d;
  LineRow[] line_rows;
  YAxesGroup axes;
  BoundingBox bounding_box;
  int n; // number of data points (rows)
  PGraphics top_layer;
  
  ParallelCoordinates(Data d) {
    this.d = d;
    n = d.num_rows;
    axes = new YAxesGroup(d);
    bounding_box = new BoundingBox();
    
    // initialize a LineRow object for each row of the data
    line_rows = new LineRow[d.num_rows];
    for (int i=0; i < d.num_rows; i++) {
      line_rows[i] = new LineRow(axes, d.get_row(i), d.get_row_label(i));
    }
    
    top_layer = createGraphics(width, height);
  }
  
  void draw() {
    top_layer.beginDraw();
    top_layer.background(0, 0, 0, 0);
    top_layer.endDraw();
    axes.draw(top_layer);
    // draw the line segments for each of the rows
    // draw the ones that are NOT highlighted first
    for (int i=0; i < d.num_rows; i++) {
      if (!line_rows[i].highlighted) {
        line_rows[i].draw();
      }
    }
    // keep track of tooltips we need to draw at the end (so they are on top)
    Tooltip[] tooltip_list = {};
    
    // next draw the highlighted ones, so they appear on top
    for (int i=0; i < d.num_rows; i++) {
      if (line_rows[i].highlighted) {
        line_rows[i].draw();
        tooltip_list = line_rows[i].get_tooltips();
      }
    }
    
    bounding_box.draw();
    
    // tooltips one top
    for (int i=0; i < tooltip_list.length; i++) {
      tooltip_list[i].draw();
    }
    // draw the top layer last
    image(top_layer, 0, 0);
  }
  
  // unhide all of the line rows
  void unhide_all() {
    for (int i=0; i < d.num_rows; i++) {
      line_rows[i].unhide();
    }
  }
  
  // to be called in the mousePressed event handling
  // check for clicking on axes and drawing bounding boxes
  void mouse_pressed() {
    if (axes.mouse_pressed()) {
      // user may be selecting a range, so don't draw the bounding box
      bounding_box.make_invisible();
    }
    else {
      bounding_box.mouse_pressed();
    }
    //unhide_all();
  }
  
  // clear the bounding box selection and range selections
  void clear() {
    // show all the lines
    for (int i=0; i < n; i++) {
      line_rows[i].unhide();
    }
    
    axes.clear_ranges();
    bounding_box.make_invisible();
  }
  
  void mouse_dragged() {
    axes.mouse_dragged();
    bounding_box.mouse_dragged();
    update_show_hide();
  }
  
  void update_show_hide() {
    // check for intersections of all lines with the bounding box
    // also check to make sure the lines are in the axis ranges
    
    for (int i=0; i < d.num_rows; i++) {
      if (axes.in_range(line_rows[i])) {
        if (bounding_box.mode != bounding_box.INVISIBLE_MODE) {
          if (line_rows[i].intersect_box(bounding_box)) {
            line_rows[i].unhide();
          }
          else {
            line_rows[i].hide();
          }
        }
        else {
          line_rows[i].unhide();
        }
      }
      else {
        line_rows[i].hide();
      }
    }
  }
  
  void mouse_moved() {
    // check for hovering over lines
    for (int i=0; i < n; i++) {
      line_rows[i].mouse_hover();
    }
  }
}