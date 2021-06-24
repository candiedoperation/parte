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

public class Parte.Utils.VirtualDisplayServer : GLib.Object {
	public signal void server_initialized ();
	
    static VirtualDisplayServer _instance = null;
    public static VirtualDisplayServer instance {
        get {
            if (_instance == null) {
                _instance = new VirtualDisplayServer ();
            }
            return _instance;
        }
    }
    
    public VirtualDisplayServer () {}
    construct {}    
            
    public void StartDisplayServer (string client_IP_address, string clip_data) {
	    try { Process.spawn_command_line_sync ("killall x11vnc"); } catch (SpawnError e) {}
	    try {
		    string[] spawn_args = {"x11vnc", "-allow", client_IP_address, "-rfbport", "43105", "-nocursorshape", "-nocursorpos", "-noxinerama", "-solid", "-clip", clip_data};
		    string[] spawn_env = Environ.get ();
			Pid child_pid;

		    int standard_input;
		    int standard_output;
		    int standard_error;

		    Process.spawn_async_with_pipes ("/",
			    spawn_args,
			    spawn_env,
			    SpawnFlags.SEARCH_PATH | SpawnFlags.DO_NOT_REAP_CHILD,
			    null,
			    out child_pid,
			    out standard_input,
			    out standard_output,
			    out standard_error);

		    IOChannel output = new IOChannel.unix_new (standard_output);
		    output.add_watch (IOCondition.IN | IOCondition.HUP, (channel, condition) => {
			    return process_line (channel, condition, "stdout");
		    });

		    IOChannel error = new IOChannel.unix_new (standard_error);
		    error.add_watch (IOCondition.IN | IOCondition.HUP, (channel, condition) => {
			    return process_line (channel, condition, "stderr");
		    });

		    ChildWatch.add (child_pid, (pid, status) => {
			    Process.close_pid (pid);
		    });
	    } catch (SpawnError e) {
		    print ("Error: %s\n", e.message);
	    }                
    }
    
	private bool process_line (IOChannel channel, IOCondition condition, string stream_name) {
		if (condition == IOCondition.HUP) {
			print ("%s: Display Server has been closed.\n", "VDS");
			return false;
		}

		try {
			string line;
			channel.read_line (out line, null, null);
			print ("%s: %s", "VDS", line);
			if ("Listening for VNC connections on TCP port 43105" in line) { server_initialized (); }
		} catch (IOChannelError e) {
			print ("%s: VDS: IOChannelError: %s\n", "VDS", e.message);
			return false;
		} catch (ConvertError e) {
			print ("%s: VDS: ConvertError: %s\n", "VDS", e.message);
			return false;
		}

		return true;
	}    
}
