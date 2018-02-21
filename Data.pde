class Data {
  String[] column_labels;
  String[] data_labels;
  float[][] data;
  int num_rows, num_dim;
  
  Data(String filename) {
    load_data(filename);
  }
  
  void load_data(String filename) {
     String[] lines = loadStrings(filename);
     num_rows = lines.length - 1;
     
     // get column labels from the first line
     String[] first_row = split(lines[0], ','); 
     column_labels = new String[first_row.length - 1];
     for (int i=1; i < first_row.length; i++) {
       column_labels[i-1] = first_row[i];
     }

     num_dim = first_row.length - 1;
     
     // initialize data arrays according to known data dimensions
     data = new float[num_rows][num_dim];
     data_labels = new String[num_rows];
     
     for (int i=1; i < lines.length; i++) {
       float[] row_data = new float[num_dim];
       String[] row = split(lines[i], ',');
       data_labels[i-1] = row[0]; // the label for this data point
       
       for (int j=1; j < row.length; j++) {
         row_data[j-1] = float(row[j]);
       }
       
       data[i-1] = row_data;
     }
  }
  
  // get the ith column of the data (i starting at 0)
  float[] get_column(int i) {
    float[] col = new float[num_rows];
    for (int row=0; row < num_rows; row++) {
      col[row] = data[row][i];
    }
    return col;
  }
  
  // get the ith row of data
  float[] get_row(int i) {
    return data[i];
  }
  
  String get_row_label(int i) {
    return data_labels[i];
  }
  
  // get the maximum value from column col_index
  float get_max_value(int col_index) {
    return max(get_column(col_index));
  }
  
  float get_min_value(int col_index) {
    return min(get_column(col_index));
  }
}
 