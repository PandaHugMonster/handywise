/* -*- Mode: C; indent-tabs-mode: t; c-basic-offset: 4; tab-width: 4 -*-  */
/*
 * main.c
 * Copyright (C) 2014 Ivan Ponomarev <ivan@newnauka.org>
 * 
 * MyHandbookOfWisdom is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the
 * Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * MyHandbookOfWisdom is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License along
 * with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

using GLib;
using Gtk;

public class WisdomBook : Gtk.Application {
	const string APP_ID = "org.dibujo.appsforlife.handywise";
	
	 
	const string UI_FILE = "ui/handywise.ui";
	

	protected TextBuffer contentBuffer;
	protected Soup.Session session;
	protected Button aboutButton;
	protected HeaderBar ab;
	protected HeaderBar lb;
	protected SimpleAction openAboutAction;
	protected ApplicationWindow window;
	protected Builder builder;
	protected Gtk.Spinner spinner;
	protected Gtk.Popover pop;

	protected string UriSource = "http://api.icndb.com/jokes/random"; //"http://api.theysaidso.com/qod";
	// protected string UriSource = "http://api.valadoc.org/soup-samples/my-secret.txt";

	
	private void newWindow() {
		this.window = builder.get_object ("BaseWindow") as ApplicationWindow;
		this.window.title = "My shiny app";
		this.aboutButton = builder.get_object("AboutButton") as Button;
		this.contentBuffer = builder.get_object("contentbuffer") as TextBuffer;
		this.spinner = new Gtk.Spinner();
		this.spinner.hide();
		Gtk.Box popmenu = new Gtk.Box(Gtk.Orientation.VERTICAL, 2);
		this.pop = new Gtk.Popover(this.aboutButton);
		this.pop.set_modal(false);
		this.pop.add(popmenu);

		var updbut = new Gtk.Button.from_icon_name("gtk-refresh", Gtk.IconSize.BUTTON);
		var clrbut = new Gtk.Button.from_icon_name("gtk-clear", Gtk.IconSize.BUTTON);
		popmenu.pack_start(updbut);
		popmenu.pack_start(clrbut);
		popmenu.show_all();
		
		this.ab = new HeaderBar();
		this.lb = new HeaderBar();
		Gtk.Box head = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);

		head.add(this.lb);
		//head.add(this.ab);
		
		this.openAboutAction = new SimpleAction("refresh-data", null);
		Image openAboutImage = new Image();
		
		this.window.application = this;
		//this.window.set_titlebar(head);
		this.window.set_titlebar(this.ab);

		this.ab.show_close_button = true;
		this.ab.set_title("My shiny app");
		this.ab.set_subtitle("Everyday quote application");
		this.ab.pack_start(aboutButton);
		//this.lb.pack_start(aboutButton);
//		Goa.Client goac = new Goa.Client();
		
		this.ab.pack_end(this.spinner);
	
		//this.aboutButton.related_action = openAboutAction as Gtk.Action;
		
		//aboutButton.use_action_appearance = false;
		
		openAboutImage.icon_name = "gtk-refresh";
		//this.aboutButton.image = openAboutImage;
		updbut.clicked.connect(() => {
			this.pop.hide();
			this.spinner.show();
			this.contentBuffer.text = this.getQuote();
			this.spinner.hide();
		});
		clrbut.clicked.connect(() => {
			this.pop.hide();
			this.contentBuffer.text = "";
		});
		this.aboutButton.clicked.connect(() => {
			if (this.pop.is_visible())
				this.pop.hide();
			else
				this.pop.show();
		});
		this.spinner.hide();
		this.setContent();
	}

	protected void setContent(string data = "hello my dear friends") {
		this.contentBuffer.text = data;
	}
	 
	protected override void startup() {
		base.startup();

		try {
			this.builder = new Builder();
			this.builder.add_from_file(UI_FILE);
			this.builder.connect_signals(this);
			this.session = new Soup.Session();
		} 
		catch (Error e) {
			stderr.printf ("Could not load UI: %s\n", e.message);
		}
		
	}

	protected string getQuote() {
		this.spinner.active = true;
		string res = null;
		try {
		
			Soup.Request request = this.session.request(this.UriSource);
			InputStream stream = request.send();

			// Print the content:
			DataInputStream data_stream = new DataInputStream (stream);
			

			string? line;
			while ((line = data_stream.read_line ()) != null) {
				res = line;
			}
		} catch (Error e) {
			stderr.printf ("Error: %s\n", e.message);
		}

		Json.Parser parser = new Json.Parser ();
		try {
			parser.load_from_data(res);
			Json.Object root = parser.get_root().get_object();
			res = root.get_object_member("value").get_string_member("joke");

		
			
		} catch (Error e) {
			stdout.printf ("Unable to parse the string: %s\n", e.message);
		}
		this.spinner.active = false;
		
		return res;
	}
	 
	protected override void activate() {
		this.newWindow();
		this.contentBuffer.text = this.getQuote();
		
		this.window.show_all();
	} 
	 
	public WisdomBook() {
		Object(application_id: APP_ID);
	}


	[CCode (instance_pos = -1)]
	public void on_aboutdialog1_close(Window w) {
		//w.hide();
	}
	[CCode (instance_pos = -1)]
	public void on_destroy (Window window) {
		Gtk.main_quit();
		//window.hide ();
	}

	static int main (string[] args) {
		WisdomBook app = new WisdomBook();
		return app.run(args);
	}
}

