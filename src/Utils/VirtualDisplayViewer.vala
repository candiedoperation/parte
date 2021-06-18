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

public class Parte.Utils.VirtualDisplayViewer : Gtk.Grid {
    private Vnc.Display vnc_display;
    private Gtk.Grid main_grid;
    public signal void hide_application ();
    public signal void request_fullscreen ();
    public signal void request_unfullscreen ();
            
    public VirtualDisplayViewer (string IP_address, string IP_port) {
        main_grid = new Gtk.Grid ();
        main_grid.hexpand = true;
        main_grid.vexpand = true;
        
        show_connecting ();
        
        vnc_display = new Vnc.Display ();
        vnc_display.hexpand = true;
        vnc_display.vexpand = true;
        vnc_display.halign = Gtk.Align.CENTER;
        vnc_display.valign = Gtk.Align.CENTER;
        vnc_display.read_only = true;
        vnc_display.lossy_encoding = true;        
        vnc_display.open_host (IP_address, IP_port);
        
        vnc_display.vnc_error.connect (show_connect_error);
        vnc_display.vnc_auth_failure.connect (show_auth_error);
        vnc_display.vnc_initialized.connect (start_display_streaming);
        vnc_display.vnc_disconnected.connect (end_display_streaming);
        
        add (main_grid);
        show_all ();                     
    }
    
    construct {}
        
    private void show_connecting () {
        var connection_status_widget = new Parte.Widgets.ConnectionStatus ();
        connection_status_widget.connection_spinner.start ();
        main_grid.remove_row (0);
        main_grid.attach (connection_status_widget, 0, 0);
        show_all ();
    }
    
    private void start_display_streaming () {
        request_fullscreen ();    
        main_grid.remove_row (0);
        main_grid.attach (vnc_display, 0, 0);
        show_all ();        
    }
    
    private void end_display_streaming () {
        request_unfullscreen ();         
    }
    
    private void show_connect_error (string error_message) {
        var connection_error_widget = new Parte.Widgets.StatusMessage ("Unable to Connect Display", error_message.substring(error_message.last_index_of (":") + 1), "dialog-error");
        connection_error_widget.action_button.label = "Close Application";
        connection_error_widget.action_button.clicked.connect (() => { hide_application (); });
        main_grid.remove_row (0);
        main_grid.attach (connection_error_widget, 0, 0);
        show_all ();        
    }
    
    private void show_auth_error (string error_message) {
        var connection_error_widget = new Parte.Widgets.StatusMessage ("Display Authentication Error", "Secondary Display Authentication Failed.", "dialog-error");
        connection_error_widget.action_button.label = "Close Application";
        connection_error_widget.action_button.clicked.connect (() => { hide_application (); });
        main_grid.remove_row (0);
        main_grid.attach (connection_error_widget, 0, 0);
        show_all ();        
    }    
}
