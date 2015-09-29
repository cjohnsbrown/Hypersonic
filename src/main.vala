/* main.vala
 *
 * Copyright (C) 2010  Cameron Johnson-Brown
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 2 of the License, or
 * (at your option) any later version.
 *  
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *  
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 * 
 * Author:
 * 	Cameron Johnson-Brown <caj4861@rit.edu>
 */

using GLib.Environment;

void main(string[] args) {
		Gtk.init(ref args);
		Gst.init(ref args);
		Notify.init("Subparsonic");
		var proxy = new Proxy();
		var loginModel = new LoginModel(proxy);
		if (loginModel.loggedIn) {
			var playModel = new PlaybackModel(proxy);
			var keys = new MediaKeys(playModel.view);
			Gtk.main();
		}
		
	}	
