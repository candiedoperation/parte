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

public class Parte.Utils.VirtualDisplayEnvironment : GLib.Object {    
    public VirtualDisplayEnvironment (double display_width, double display_height, double display_frequency) {
        var gtime_f = new Parte.Utils.GTFStandard (display_width, display_height, display_frequency);
        
        Xcb.Connection xcb_connection = new Xcb.Connection (); //Connect to X Window System
        Xcb.Setup xcb_setup = xcb_connection.get_setup (); //Get XCB Setup
        Xcb.ScreenIterator xcb_screen_iterator = xcb_setup.roots_iterator (); //Iterate available Screens
        Xcb.Screen xcb_screen = xcb_screen_iterator.data; //Get the first Screen
        
        Xcb.Window virt_display_window;
        Xcb.RandR.Connection xcb_randr_connection = Xcb.RandR.get_connection (xcb_connection);        
        Xcb.RandR.ModeInfo virt_display_modeline = Xcb.RandR.ModeInfo () {
            id = (uint32) xcb_connection.generate_id (),
            dot_clock = (uint32) gtime_f.EST_PIXEL_FREQ,
            width = (uint16) gtime_f.OPT_HOR_RESOL,
            hsync_start = (uint16) gtime_f.HOR_SYNC_START,
            hsync_end = (uint16) gtime_f.HOR_SYNC_END,
            htotal = (uint16) gtime_f.HOR_WID_TOTAL,
            hskew = (uint16) 0,
            height = (uint16) gtime_f.OPT_VERT_RESOL,
            vsync_start = (uint16) gtime_f.VER_SYNC_START,
            vsync_end = (uint16) gtime_f.VER_SYNC_END,
            vtotal = (uint16) gtime_f.VER_HEIG_TOTAL,
            mode_flags = Xcb.RandR.ModeFlag.HSYNC_NEGATIVE + Xcb.RandR.ModeFlag.VSYNC_POSITIVE,
            name_len = (uint16) gtime_f.RANDR_MODE_NAME            
        };
        
        virt_display_window = xcb_connection.generate_id ();       
        xcb_connection.create_window (
            Xcb.COPY_FROM_PARENT, // Copy Window Depth from Parent Window
            virt_display_window, // Use the newly created window
            xcb_screen.root, // Use root window as the Parent Window
            0, 0, // X, Y coords
            1, 1, // End X, Y coords (Lower than 1 fails creation)
            0, // Window Border Width
            Xcb.WindowClass.INPUT_OUTPUT, // Add Window Class
            xcb_screen.root_visual, // Set VisualID same as the first screen
            0, // Window Masks
            {} // Window Masks
        );
        
        xcb_connection.flush ();
        
        Xcb.RandR.GetScreenResourcesReply screen_resources = xcb_randr_connection.get_screen_resources_reply (xcb_randr_connection.get_screen_resources (virt_display_window));
        loopup (screen_resources);
        print ("-------------");
        Xcb.RandR.CreateModeReply virt_display_mode_reply = xcb_randr_connection.create_mode_reply (xcb_randr_connection.create_mode (virt_display_window, screen_resources.modes [2], gtime_f.RANDR_MODE_NAME)); // Get the created mode from CreateModeReply
        screen_resources = xcb_randr_connection.get_screen_resources_reply (xcb_randr_connection.get_screen_resources (virt_display_window));
        loopup (screen_resources);        
        Xcb.RandR.Output virt_display_output;
        
        foreach (Xcb.RandR.Output output in screen_resources.outputs) {
            Xcb.RandR.GetOutputInfoReply output_info = xcb_randr_connection.get_output_info_reply (xcb_randr_connection.get_output_info (output, screen_resources.config_timestamp));          
            if (output_info.name == "VIRTUAL1") {
                virt_display_output = output;
                //xcb_randr_connection.add_output_mode (virt_display_output, virt_display_mode_reply.mode);                
                break;
            }
        }
    }
    
    
    private void loopup (Xcb.RandR.GetScreenResourcesReply data) {
        foreach (var modename in data.mode_names) {
            print ("\n" + modename + "\n");
        }
    }    
    
    construct {
        //Ask Graphic Card to create Virtual Display `nano /usr/share/X11/xorg.conf.d/20-intel.conf`
    }
}
