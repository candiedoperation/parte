/*
    Parte
    Copyright (C) 2021  Atheesh Thirumalairajan

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
    
    Authored By: Atheesh Thirumalairajan <candiedoperation@icloud.com>
*/

public class Parte.Widgets.DisplayPairRow : Gtk.Grid {
    public DisplayPairRow (string title, string icon = "video-display") {
        Gtk.Label device_name = new Gtk.Label (title);
        device_name.get_style_context ().add_class (Granite.STYLE_CLASS_H2_LABEL);
        
        Gtk.Image display_icon = new Gtk.Image ();
        display_icon.gicon = new ThemedIcon (icon);
        display_icon.pixel_size = 38;
        
        Gtk.Grid main_grid = new Gtk.Grid ();
        main_grid.hexpand = true;
        main_grid.column_spacing = 5;
        main_grid.margin = 5;
        main_grid.attach (display_icon, 0, 0);        
        main_grid.attach (device_name, 1, 0);
        
        add (main_grid);
        show_all ();
    }
    
    construct {
      
    }
}
