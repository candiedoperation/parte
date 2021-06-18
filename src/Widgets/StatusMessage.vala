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

public class Parte.Widgets.StatusMessage : Gtk.Grid {
    public Gtk.Button action_button;
                    
    public StatusMessage (string title, string description, string icon_name) {        
        var title_label = new Gtk.Label (title);
        title_label.hexpand = true;
        title_label.xalign = (float) 0.0;
        title_label.get_style_context ().add_class (Granite.STYLE_CLASS_H1_LABEL);
        
        var subtitle_label = new Gtk.Label (description);
        subtitle_label.hexpand = true;
        subtitle_label.xalign = (float) 0.0;
        subtitle_label.get_style_context ().add_class (Granite.STYLE_CLASS_H2_LABEL);
        
        var status_icon = new Gtk.Image ();
        status_icon.gicon = new ThemedIcon (icon_name);
        status_icon.pixel_size = 65;  
        
        action_button = new Gtk.Button ();
        action_button.label = "Close";
        action_button.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
        action_button.halign = Gtk.Align.END;           
        
        var label_grid = new Gtk.Grid ();
        label_grid.row_spacing = 0;
        label_grid.column_spacing = 0;
        label_grid.attach (title_label, 0, 0);
        label_grid.attach (subtitle_label, 0, 1);   
        
        var status_grid = new Gtk.Grid ();
        status_grid.hexpand = true;
        status_grid.vexpand = true;
        status_grid.column_spacing = 10;
        status_grid.row_spacing = 5;
        status_grid.halign = Gtk.Align.CENTER;
        status_grid.valign = Gtk.Align.CENTER;
        status_grid.attach (status_icon, 0, 0);
        status_grid.attach (label_grid, 1, 0);
        status_grid.attach (action_button, 1, 1);        
        
        add (status_grid);
        show_all ();                         
    }
    
    construct {
        
    }
}
