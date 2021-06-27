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

public class Parte.App : Gtk.Application {
    private Parte.MainWindow window;
    private Parte.Utils.VirtualDisplayEnvironment virtual_display;
    private Parte.Utils.DisplayNetwork display_network;
    private Granite.MessageDialog message_dialog;
    
    construct {
        application_id = "com.github.candiedoperation.parte";
        flags = ApplicationFlags.FLAGS_NONE;
    }

    public override void activate () {
        if (get_windows () != null) {
            get_windows ().data.present (); // present window if app is already running
            return;
        }
            
        Hdy.init (); //Initializing LibHandy
        virtual_display = Parte.Utils.VirtualDisplayEnvironment.instance; //Initializing Virtual Display Module
        display_network = Parte.Utils.DisplayNetwork.instance;
        
        window = new Parte.MainWindow ();
        window.application = this;
        window.window_position = Gtk.WindowPosition.CENTER;
        window.show_all ();
        
        window.hide_application.connect(() => {
            this.hold ();
            window.hide ();
        });
        
        window.delete_event.connect(() => {
            initialize_exit_message ();                    
            message_dialog.show_all ();
            return true;                        
        });
    }
    
    private void initialize_exit_message () {
        message_dialog = new Granite.MessageDialog.with_image_from_icon_name (
            "Close Parte?",
            "Closing Parte will disconnect all external monitors and prevent this monitor from being discovered.",
            "dialog-warning",
            Gtk.ButtonsType.NONE                
        );

        message_dialog.transient_for = window;

        Gtk.Button close_app_button = new Gtk.Button.with_label ("Close Parte");
        close_app_button.get_style_context ().add_class (Gtk.STYLE_CLASS_DESTRUCTIVE_ACTION);
        message_dialog.add_action_widget (close_app_button, Gtk.ResponseType.ACCEPT);

        Gtk.Button hide_app_button = new Gtk.Button.with_label ("Run In Background");
        hide_app_button.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
        message_dialog.add_action_widget (hide_app_button, Gtk.ResponseType.CLOSE);

        message_dialog.response.connect ((response_id) => {
            if (response_id == Gtk.ResponseType.ACCEPT) {
                close_app_button.sensitive = false;
                hide_app_button.sensitive = false;                    

                virtual_display.reset_display_modes (); //FUNCTION DOES NOT WORK AS INTENDED
                display_network.close_socket_server ();
                Parte.Utils.VirtualDisplayServer.instance.destroy_server ();
                this.quit ();
            } else if (response_id == Gtk.ResponseType.CLOSE) {
                message_dialog.destroy ();                    
                this.hold ();
                window.hide ();                    
            } 
        });    
    }    
}

public static int main (string[] args) {
    var application = new Parte.App ();
    return application.run (args);
}
