// modules: gtk+-2.0 gee-1.0 Song
using Gtk;
using Gee;

public class PlaybackView : Window {
	
	private PlaybackModel model;


	private ToolButton pauseBtn = new ToolButton.from_stock(Stock.MEDIA_PLAY);
	private TreeView tview = new TreeView();
	private ToolButton shuffBtn;
	private ScrolledWindow scroll = new ScrolledWindow(null, null);
	private Image loadImg = new Image.from_file("rolling.gif");
	private Box vbox = new Box(Orientation.VERTICAL, 0);

	public PlaybackView(PlaybackModel model) throws Error { 
		this.model = model;
		this.title = "Hypersonic";
		set_default_size(870,600);
		tview.row_activated.connect((a, b) => {
				 on_row_clicked(a);
				});
		foreach (var col in tview.get_columns()) {
			col.resizable = true;
			col.spacing = 5;
		}

		scroll.set_policy(PolicyType.AUTOMATIC, PolicyType.AUTOMATIC);
		scroll.add(tview);

		var toolbar = new Toolbar();
		var hbox = new Box(Orientation.HORIZONTAL, 1);
		var prevBtn = new ToolButton.from_stock(Stock.MEDIA_PREVIOUS);
		prevBtn.clicked.connect(on_prev_clicked);
		toolbar.add(prevBtn);
		pauseBtn.clicked.connect(on_pause_clicked);
		toolbar.add(pauseBtn);
		var nextBtn = new ToolButton.from_stock(Stock.MEDIA_NEXT);
		nextBtn.clicked.connect(on_next_clicked);
		toolbar.add(nextBtn);
		var shuffImg = new Image.from_file("shuffle.png");
		shuffBtn = new ToolButton(shuffImg, "Shuffle");
		shuffBtn.clicked.connect(on_shuffle_clicked);
		shuffBtn.opacity = 0.3;
		toolbar.add(shuffBtn);
		var volBtn = new VolumeButton();
		volBtn.set_value(1);
		volBtn.value_changed.connect((val) => {
			model.set_volume(val);
		});
		hbox.add(toolbar);
		hbox.add(volBtn);

		var posSlider = new Scale.with_range(Orientation.HORIZONTAL,0,100000,10000);
		posSlider.set_restrict_to_fill_level(true);
		model.sliderAdj = posSlider.get_adjustment();
		posSlider.set_draw_value(false);
		posSlider.change_value.connect((s, v) => {
				on_slider_moved(v);
				return false;
				});

		vbox.pack_start(hbox, false, true, 0);
		vbox.pack_start(posSlider, false, true, 0);
		vbox.pack_start(loadImg,true,true,0);
		add(vbox);
		this.destroy.connect(on_close);
	}

	

	public void setup_treeview() {
		var listmodel = new ListStore(4, typeof(string), typeof(string), typeof(string),
										typeof(string));
		TreeViewColumn col;
		tview.set_model(listmodel);
		tview.insert_column_with_attributes(-1, "Title", new CellRendererText(), "text", 0);
		col = tview.get_column(0);
		col.fixed_width = 300;
		tview.insert_column_with_attributes(-1, "Aritist", new CellRendererText(), "text", 1);
		col = tview.get_column(1);
		col.fixed_width = 200;
		tview.insert_column_with_attributes(-1, "Album", new CellRendererText(), "text", 2);
		col = tview.get_column(2);
		col.fixed_width = 300;
		tview.insert_column_with_attributes(-1, "Length", new CellRendererText(), "text", 3);
		col = tview.get_column(3);
		col.fixed_width = 30;
		tview.show_expanders = true;

		TreeIter iter;
		foreach (var song in model.songs) {
			listmodel.append(out iter);
			listmodel.set(iter, 0, song.title, 1, song.artist, 2, song.album, 3, song.length);
			song.treePath = listmodel.get_path(iter);
		}
		loadImg.destroy();
		vbox.pack_end(scroll, true, true, 0);
		this.show_all();
	}


	private void on_row_clicked(TreePath path) {
		pauseBtn.set_stock_id(Stock.MEDIA_PAUSE);
		var index = int.parse(path.to_string());
		this.set_title(model.manualStart(index));
		
	}

	public void on_pause_clicked() {
		if (model.paused)
			pauseBtn.set_stock_id(Stock.MEDIA_PAUSE);
		else 
			pauseBtn.set_stock_id(Stock.MEDIA_PLAY);
		model.pause();
	}
	
	public void on_next_clicked() {
		this.set_title(model.next_song());
	}

	public void on_prev_clicked() {
		this.set_title(model.prev_song());
	}

	private void on_slider_moved(double val) {
		model.seek(val);
	}

	private void on_shuffle_clicked() {
		if (model.shuffled)
			shuffBtn.opacity = 0.3;
		else 
			shuffBtn.opacity = 1;
		model.shuffle();
	}

	public void move_cursor(TreePath path) {
		tview.set_cursor(path, null, false);
	}


	public void on_close() {
		model.close();
		Gtk.main_quit();
	}

	//public void set_pos_label(int position) {
		//string time;
		//var seconds = position % 60;
		//var minutes = position / 60;
		//time = seconds.to_string();
		//if (seconds < 10)
			//time = "0" + length;
		//time = minutes.to_string() + ":" + length;
		//posLabel.set_text(label);
	//}

}
