import java.awt.*;
import java.io.*;
// import java.util.*;
// import org.jfree.chart.imagemap.*;
import org.jfree.chart.*;
import org.jfree.chart.entity.*;
import org.jfree.chart.plot.*;
import org.jfree.data.category.*;
import org.jfree.data.general.*;
import org.jfree.util.*;
import org.jfree.ui.TextAnchor;
import org.jfree.chart.labels.*;
import org.jfree.chart.renderer.xy.*;
import org.jfree.chart.renderer.category.*;
import org.jfree.data.xy.*;
import org.jfree.chart.axis.*;
// import org.jfree.chart.labels.*;
import org.jfree.chart.urls.*;
import java.net.URLEncoder;
import java.awt.image.BufferedImage;
/**
 * Creates an HTML image map for a multiple pie chart.
 */
public class CreateChart {
    
    public class MyGenerator implements CategoryURLGenerator,
					CategoryToolTipGenerator,
					PieURLGenerator,
					PieToolTipGenerator,
					XYURLGenerator,
					XYToolTipGenerator   {
	private String prefix = "index.html";
	private String seriesParameterName = "series";
	private String categoryParameterName = "category";
	private String rangeParameterName = "range";
	private String rangeKey = null;
	private CreateChart createChart = null;

	private CategoryDataset theDataset = null;
	
	public MyGenerator(String prefix, CategoryDataset ds) {
	    super();
	    this.prefix = prefix;
	    this.theDataset = ds;
	}
	
	public MyGenerator(String prefix) {
	    this.prefix = prefix;
	}
	public MyGenerator(String prefix, String rangeKey, CreateChart createChart) {
	    this.prefix = prefix;
	    this.rangeKey = rangeKey;
	    this.createChart = createChart;
	}
	
	public MyGenerator(String prefix,
				      String seriesParameterName,
				      String categoryParameterName) {
	    this.prefix = prefix;
	    this.seriesParameterName = seriesParameterName;
	    this.categoryParameterName = categoryParameterName;
	}

	public MyGenerator(String prefix,
				      String seriesParameterName,
				      String categoryParameterName,
				      String rangeParameterName,
				      String rangeKey) {
	    this.prefix = prefix;
	    this.seriesParameterName = seriesParameterName;
	    this.categoryParameterName = categoryParameterName;
	    this.rangeParameterName = rangeParameterName;
	    this.rangeKey = rangeKey;
	}
	
	public String myGenerateURL(Comparable seriesKey, Comparable categoryKey, Comparable rangeKey) {
	    if (categoryKey.toString().equals("<<REST>>") || 
		seriesKey.toString().equals("<<REST>>") ||
		(rangeKey != null && rangeKey.toString().equals("<<REST>>"))) { return "";}

	    String url = this.prefix;
	    boolean firstParameter = url.indexOf("?") == -1;

	    if (categoryKey.toString().equals("rest_value")) { return "";}
	    if (seriesKey.toString().equals("rest_serie")) { return "";}
	    
	    url += firstParameter ? "?" : "&";
	    try {
		url += this.seriesParameterName + "=" 
		    + URLEncoder.encode(seriesKey.toString(),"UTF-8");
		url += "&" + this.categoryParameterName + "=" 
                + URLEncoder.encode(categoryKey.toString(),"UTF-8");
		if (rangeKey != null) {
		    url += "&" + this.rangeParameterName + "=" 
			+ URLEncoder.encode(rangeKey.toString(),"UTF-8");
		}
	    }
	    catch ( java.io.UnsupportedEncodingException uee ) {
		uee.printStackTrace();
	    }	
	    
	    return url;	   	    	   	    
	}
	
	public String myGenerateToolTip(Comparable seriesKey, Comparable categoryKey, Comparable rangeKey, Number value) {	    
	    String text = "";
	    if (this.rangeKey != null && !this.rangeKey.equals("<<NULL>>")) {
		text += this.rangeKey + ", ";
	    }
	    
	    if (seriesKey != null && !seriesKey.toString().equals("<<NULL>>")) {
		text += seriesKey.toString() + ", ";
	    }

	    text += this.createChart.xAxis + "=" + categoryKey.toString() + ", ";
	
	    text += "value: " + value;
	    return text;	    
	}

	/** Pie **/

	public String generateURL(PieDataset data, Comparable categoryKey, int pieIndex) {    	    
	    Comparable seriesKey = theDataset.getRowKey(pieIndex);
	    return myGenerateURL(seriesKey, categoryKey, null);
 	}
	public String generateToolTip(PieDataset data, Comparable categoryKey) {
	    /** not working **/
	    Comparable seriesKey = theDataset.getRowKey(0);
	    return myGenerateToolTip(seriesKey, categoryKey, null,999);
	}

	
	/** Category **/

	public String generateURL(CategoryDataset dataset,
				  int series, 
				  int category) {	    
	    Comparable seriesKey = dataset.getRowKey(series);
	    Comparable categoryKey = dataset.getColumnKey(category);

	    return myGenerateURL(seriesKey, categoryKey, this.rangeKey);
	}

	public String generateToolTip(CategoryDataset dataset, 
				      int series, int category) {
	    Comparable seriesKey = dataset.getRowKey(series);
	    Comparable categoryKey = dataset.getColumnKey(category);

	    return myGenerateToolTip(seriesKey, categoryKey, this.rangeKey,dataset.getValue(seriesKey,categoryKey));
	}

	/** XY **/
	public String generateURL(XYDataset dataset, int series, int item) {
	    Comparable seriesKey = dataset.getSeriesKey(series);
	    Comparable categoryKey = (Comparable)dataset.getX(series,item);

	    return myGenerateURL(seriesKey, categoryKey, this.rangeKey);
	}

	public String generateToolTip(XYDataset dataset, int series, int item) {
	    Comparable seriesKey = dataset.getSeriesKey(series);
	    Comparable categoryKey = (Comparable)dataset.getX(series,item);

	    return myGenerateToolTip(seriesKey, categoryKey, this.rangeKey,dataset.getY(series,item));
	}


    }


    public static final boolean LEGEND = true;
    public static final boolean TOOL_TIPS = true;
    public static final boolean URLS = true;

    public String filebase;
    public JFreeChart chart;
    public CategoryDataset[] category_datasets;
    public XYDataset[] xy_datasets;
    public String[] rangeNames;
    public PieDataset pie_dataset;
    public String htmlFile;
    public String imageMapFile;
    public String imageFile;
    public String URLPrefix;

    public String chartTitle;
    public String xAxis;
    public String yAxis;
    public String type;
    public boolean stacked = false;
    public PlotOrientation orientation;

    public int rangeCount = 0;
    public int serieCount = 0;

    public int width = 600;
    public int height = 400;
    
    /**
     * Default constructor.
     */
    public CreateChart(String filebase, String URLPrefix) {
	super();
	this.filebase = filebase;
	this.htmlFile = filebase + ".html";
	this.imageMapFile = filebase + ".map";
	this.imageFile = filebase + ".png";
	this.URLPrefix = URLPrefix;
    }

    public void saveFiles() {	 
	
	// save it to an image
	try {
	    ChartRenderingInfo info = new ChartRenderingInfo(new StandardEntityCollection());
	    File file1 = new File(this.imageFile);
	    ChartUtilities.saveChartAsPNG(file1, chart, this.width, this.height, info);
	    
	    // write an HTML page incorporating the image with an image map
	    File file2 = new File(this.htmlFile);
	    OutputStream out = new BufferedOutputStream(new FileOutputStream(file2));
	    PrintWriter writer = new PrintWriter(out);
	    writer.println("<HEAD><TITLE>JFreeChart Image Map</TITLE></HEAD>");
	    writer.println("<BODY>");
	    writer.println(ChartUtilities.getImageMap("chart", info));
	    writer.println("<IMG SRC=\"" + this.imageFile  + "\" "
			   + "WIDTH=\"" + this.width +"\" HEIGHT=\"" + this.height + "\" BORDER=\"0\" USEMAP=\"#chart\">");
             writer.println("</BODY>");
             writer.println("</HTML>");
             writer.close();
	     
             File file3 = new File(this.imageMapFile);
             out = new BufferedOutputStream(new FileOutputStream(file3));
             writer = new PrintWriter(out);
	     writer.println(ChartUtilities.getImageMap("chart", info));
             writer.close();
	     
	}
	catch (IOException e) {
	    System.out.println(e.toString());
	}
	
    }

    private Object callFunction(Object obj, String name) throws Exception {
	return callFunction(obj,name,new Object[] {});
    }
    private Object callFunction(Object obj, String name, Object arg) throws Exception {
	return callFunction(obj,name,new Object[] {arg});
    }
    private Object callFunction(Object obj, String name, Object[] args) throws Exception {
	Class[] classes = new Class[args.length];
	String classes_string = "";
	for (int i = 0; i<args.length; i++) {
	    classes[i] = args[i].getClass();
	    try {
		classes[i] = (Class)classes[i].getField("TYPE").get(classes[i]);
	    } catch (NoSuchFieldException ex) {
		// ok this is not a primitive type	       
	    }
	    classes_string += args[i].getClass().getName() + " ";
	}

	try {
	    return callFunction(obj, name, args, classes);
	} catch ( NoSuchMethodException e) {
	    throw new Exception("Method " + obj.getClass().getName() + "." + name + "(" + classes_string + ") not found.");
	}
    }
    
    private Object callFunction(Object obj, String name, Object[] args, Class[] classes) throws Exception {
	    return obj.getClass().getMethod(name,classes).invoke(obj,args);
    }

    private void configureColors(Object renderer) throws Exception {
	Class[] pc = new Class[] {Integer.TYPE, Class.forName("java.awt.Paint")};
	java.awt.Color secondColor = Color.white;
	int i = 0;
	if (false) {
	    for (java.awt.Paint item : ChartColor.createDefaultPaintArray()) {
		callFunction(renderer, "setSeriesPaint",
					new java.lang.Object[] 
		    {i,(java.awt.Paint)
		     new GradientPaint(
				       0.0f, 0.0f, (java.awt.Color)item, 
				       1000, 0.0f, secondColor
				       )},pc);
		i += 1;
	    }
	} else {
	    for (java.awt.Paint item : ChartColor.createDefaultPaintArray()) {
		callFunction(renderer, "setSeriesPaint",
					new java.lang.Object[] 
		    {i, (java.awt.Paint)item },pc);
		i += 1;
	    }
	}
	
	for (java.awt.Paint item : ChartColor.createDefaultPaintArray()) {
	    BufferedImage bi = new BufferedImage(2, 2, BufferedImage.TYPE_INT_RGB);
	    Graphics2D big = bi.createGraphics();
	    big.setColor((java.awt.Color)item);
	    big.fillRect(0, 0, 1, 1);
	    big.fillOval(1, 1, 2, 2);
	    big.setColor(secondColor);
	    big.fillRect(1, 0, 2, 1);
	    big.fillOval(0, 1, 1, 2);
	    Rectangle r = new Rectangle(0, 0, 2, 2);
	    callFunction(renderer, "setSeriesPaint",new java.lang.Object[] {i,(java.awt.Paint) new TexturePaint(bi, r)},pc);
	    i += 1;
	}
	
	for (java.awt.Paint item : ChartColor.createDefaultPaintArray()) {
	    BufferedImage bi = new BufferedImage(2, 2, BufferedImage.TYPE_INT_RGB);
	    Graphics2D big = bi.createGraphics();
	    big.setColor((java.awt.Color)item);
	    big.fillRect(0, 0, 1, 1);
	    big.fillOval(1, 0, 2, 1);
	    big.setColor(secondColor);
	    big.fillRect(0, 1, 1, 2);
	    big.fillOval(1, 1, 2, 2);
	    Rectangle r = new Rectangle(0, 0, 2, 2);
	    callFunction(renderer, "setSeriesPaint",new java.lang.Object[] {i, (java.awt.Paint)new TexturePaint(bi, r)},pc);
	    i += 1;
	}
    }

    private void correctLegend(Object plot,Object subplot) throws Exception {
	
	Object li = callFunction(subplot,"getLegendItems");
	callFunction(plot,"setFixedLegendItems",new Object[] { li });
	if (((Integer)callFunction(li,"getItemCount")) == 1 && 
	    ((String)callFunction(callFunction(li,"get",0),"getLabel")).equals("<<NULL>>")) {
	    callFunction(plot,"setFixedLegendItems",new LegendItemCollection());
	}
    }
    
     
    
    private XYItemRenderer createLineRenderer() throws Exception {
	XYItemRenderer renderer;
	if (this.stacked)
	    renderer = new StackedXYAreaRenderer2();
	else
	    renderer = new StandardXYItemRenderer( StandardXYItemRenderer.SHAPES_AND_LINES);
	configureColors(renderer);
	return renderer;
    }
    private BarRenderer createBarRenderer() throws Exception {
	// RENDERER	
        BarRenderer renderer;
	if (this.stacked)
	    renderer = new StackedBarRenderer();
	else
	    renderer = new BarRenderer();
	
	ItemLabelPosition position1 = new ItemLabelPosition(ItemLabelAnchor.OUTSIDE12, TextAnchor.BOTTOM_CENTER);
	ItemLabelPosition position2 = new ItemLabelPosition(ItemLabelAnchor.OUTSIDE6, TextAnchor.TOP_CENTER);
	renderer.setPositiveItemLabelPosition(position1);
	renderer.setNegativeItemLabelPosition(position2);	
	renderer.setDrawBarOutline(false);
	configureColors(renderer);
	return renderer;
    }



    /**
     * Creates a sample chart with the given dataset.
      * 
      * @param dataset  the dataset.
      * 
      * @return A sample chart.
      */
    private void createPieChart() throws Exception {
	this.chart = ChartFactory.createMultiplePieChart(
							       this.chartTitle,  // chart title
							       this.category_datasets[0],               // dataset
							       TableOrder.BY_ROW,
							       CreateChart.LEGEND,                  // include legend
							       CreateChart.TOOL_TIPS,
							       CreateChart.URLS
							       );
	MultiplePiePlot plot = (MultiplePiePlot) this.chart.getPlot();
	JFreeChart subchart = plot.getPieChart();
	
	PiePlot p = (PiePlot) subchart.getPlot();
	 /*         p.setLabelGenerator(new StandardPieItemLabelGenerator("{0}"));*/
	p.setLabelFont(new Font("SansSerif", Font.PLAIN, 8));
	/*	p.setLabelGap(0.2);	p.setInteriorGap(0.1);*/
	MyGenerator generator = new MyGenerator(this.URLPrefix,this.category_datasets[0]);
	p.setURLGenerator(generator);
	// p.setToolTipGenerator(generator);
    }
        
    public void createLineChart() throws Exception {
	// parent plot...
	final NumberAxis domainAxis = new NumberAxis(this.xAxis);
	domainAxis.setAutoRangeIncludesZero(false);
	domainAxis.setAutoRangeStickyZero(false);
	domainAxis.setAutoRange(true);

	final CombinedDomainXYPlot plot = new CombinedDomainXYPlot(domainAxis);
	
	//plot.setGap(10.0);
	for (int range = 0; range<rangeCount; range++) {	    

	    NumberAxis rangeAxis = new NumberAxis(this.rangeNames[range] + " " + this.yAxis);
	    if (this.rangeNames[range] == null) {
		rangeAxis = new NumberAxis(this.yAxis);
	    }
	    rangeAxis.setAutoRangeIncludesZero(true);
	    rangeAxis.setAutoRangeStickyZero(true);
	    rangeAxis.setAutoRange(true);

	    XYItemRenderer my_renderer = createLineRenderer();
	    MyGenerator generator = new MyGenerator(this.URLPrefix, this.rangeNames[range], this);
	    my_renderer.setURLGenerator(generator);
	    my_renderer.setBaseToolTipGenerator(generator);


	    final XYPlot subplot = new XYPlot(this.xy_datasets[range],
					      null, rangeAxis, my_renderer);

	    subplot.setRangeAxisLocation(AxisLocation.BOTTOM_OR_LEFT);
	    plot.add(subplot, 1);

	    correctLegend(plot, subplot);

	    plot.setOrientation(this.orientation);
	}
	
	
	// return a new chart containing the overlaid plot...
	this.chart =  new JFreeChart(this.chartTitle,
			      JFreeChart.DEFAULT_TITLE_FONT, plot, true);	
    }
    
    public void createBarChart() throws Exception {
	// create the chart...
	
	CategoryAxis categoryAxis = new CategoryAxis(this.xAxis);
	//	categoryAxis = null;
	
	
	CombinedDomainCategoryPlot plot = new CombinedDomainCategoryPlot(categoryAxis);
	
	for (int range = 0; range<rangeCount; range++) {
	    BarRenderer my_renderer = createBarRenderer();
	    MyGenerator generator = new MyGenerator(this.URLPrefix, this.rangeNames[range], this);
	    my_renderer.setBaseItemURLGenerator(generator);
	    my_renderer.setBaseToolTipGenerator(generator);

	    ValueAxis valueAxis = new NumberAxis(this.rangeNames[range] + " " + this.yAxis);
	    
	    if (this.rangeNames[range] == null) {
		valueAxis = new NumberAxis(this.yAxis);
	    }

	    CategoryPlot subplot = new CategoryPlot(this.category_datasets[range], null, valueAxis,
						    my_renderer);

	    plot.add(subplot, 1);

	    // Correct Legend
	    correctLegend(plot,subplot);

	    subplot.setOrientation(this.orientation);

	}
     

	// NOW DO SOME OPTIONAL CUSTOMISATION OF THE CHART...
	this.chart = new JFreeChart(this.chartTitle, JFreeChart.DEFAULT_TITLE_FONT,
				    plot, true);
	
	chart.setBackgroundPaint(Color.white);
	plot.setBackgroundPaint(Color.lightGray);
	plot.setDomainGridlinePaint(Color.white);
	plot.setRangeGridlinePaint(Color.white);
        
	//	plot.clearDomainAxes();
	final CategoryAxis domainAxis = plot.getDomainAxis();
	domainAxis.setCategoryLabelPositions(
					     CategoryLabelPositions.createUpRotationLabelPositions(Math.PI / 6.0)
					     );
	// OPTIONAL CUSTOMISATION COMPLETED.         
    }
    
    
    public void createXYChart() throws Exception {
        // create the chart...
        this.chart = ChartFactory.createXYLineChart(
						    this.chartTitle,      // chart title
						    this.xAxis,                      // x axis label
						    this.yAxis,                      // y axis label
						    this.xy_datasets[0],                  // data
						    this.orientation,
						    CreateChart.LEGEND,                     // include legend
						    CreateChart.TOOL_TIPS,                     // tooltips
						    CreateChart.URLS                     // urls
						    );
	
        // NOW DO SOME OPTIONAL CUSTOMISATION OF THE CHART...
        chart.setBackgroundPaint(Color.white);
        // get a reference to the plot for further customisation...
        XYPlot plot = chart.getXYPlot();
        plot.setBackgroundPaint(Color.lightGray);
        //    plot.setAxisOffset(new Spacer(Spacer.ABSOLUTE, 5.0, 5.0, 5.0, 5.0));
        plot.setDomainGridlinePaint(Color.white);
        plot.setRangeGridlinePaint(Color.white);
	
        XYLineAndShapeRenderer renderer = new XYLineAndShapeRenderer();
	//       renderer.setSeriesLinesVisible(1, false);
	//        renderer.setSeriesShapesVisible(1, false);
        plot.setRenderer(renderer);
	
        // change the auto tick unit selection to integer units only...
        NumberAxis rangeAxis = (NumberAxis) plot.getRangeAxis();
        rangeAxis.setStandardTickUnits(NumberAxis.createIntegerTickUnits());
        // OPTIONAL CUSTOMISATION COMPLETED.
        // save the image to an appropriate location : The images folder in your Instant Rails application
    }
    
    
    public void createCategory1TestData() throws Exception {
         double[][] data = new double[][] {
             {3.0, 4.0, 3.0, 5.0},
             {5.0, 7.0, 6.0, 8.0},
             {5.0, 7.0, 3.0, 8.0},
             {1.0, 2.0, 3.0, 4.0},
             {2.0, 3.0, 2.0, 3.0}
         };
	 CategoryDataset cd = DatasetUtilities.createCategoryDataset(
								     "Region ",
								     "Sales/Q",
								     data				
								     );
	 this.category_datasets = new CategoryDataset[1];
         this.category_datasets[0] = cd; 
    }
    
    

    
    public void loadDataFromStdIn() throws IOException {	
	java.io.BufferedReader stdin = new java.io.BufferedReader(new java.io.InputStreamReader(System.in));
	
	//	System.out.println("Chart title?");
	this.chartTitle = stdin.readLine();

	//	System.out.println("Width?");
	this.width = Integer.parseInt(stdin.readLine());
	//	System.out.println("Height?");
	this.height = Integer.parseInt(stdin.readLine());

	//	System.out.println("X-Axis?");
	this.xAxis = stdin.readLine();
	
	//	System.out.println("Y-Axis?");
	this.yAxis = stdin.readLine();

	//	System.out.println("Series count?");
	serieCount = Integer.parseInt(stdin.readLine());

	//	System.out.println("Range count?");
	rangeCount = Integer.parseInt(stdin.readLine());
	
	this.category_datasets = new CategoryDataset[rangeCount];
	this.xy_datasets = new CategoryTableXYDataset[rangeCount];
	this.rangeNames = new String[rangeCount];
	    
	for (int range = 0; range<rangeCount; range++) {
	    rangeNames[range] = stdin.readLine();
	    if (rangeNames[range].equals("<<NULL>>")) {
		rangeNames[range] = null;
	    }
		
	    CategoryDataset category_dataset = new DefaultCategoryDataset();
	    category_datasets[range] = category_dataset;

	    //XYSeriesCollection xy_serie = new XYSeriesCollection();
	    CategoryTableXYDataset xy_dataset = new CategoryTableXYDataset();
	    xy_datasets[range] = xy_dataset;

	    for (int serie = 0; serie<serieCount; serie++) {
		//	    System.out.println("Serie name?");
		String serieName =  stdin.readLine();

		int rowCount = Integer.parseInt(stdin.readLine());
		int columnCount = Integer.parseInt(stdin.readLine());

		//final XYSeries xy_serie = new XYSeries(serieName);
		
		for (int row = 0; row<rowCount; row++) {
		    //		System.out.println("Category name?");
		    String categoryName = stdin.readLine();		    
		    for (int col = 0; col<columnCount; col++) {
			String val = stdin.readLine();
			//		    System.out.println(val + ":" + serieName + ":" + categoryName + "\n");
			
			((DefaultCategoryDataset)category_dataset).addValue(
									    Integer.parseInt(val),
									    serieName,
									    categoryName);
			if (type.equals("line") || type.equals("lines")) {
			    //xy_serie.add(Float.parseFloat(categoryName), Float.parseFloat(val));
			    xy_dataset.add(Float.parseFloat(categoryName), Float.parseFloat(val), serieName);
			}

		    }
		}
		//		xy_serie.addSeries(xy_serie);
	    }
	}
    }
    
    /**
     * Starting point for the chart.
     *
     * @param args  ignored.
      */
    public static void main(String[] args) {
	try {	    
	    CreateChart chart = new CreateChart(args[0],args[1]);
	    chart.type = args[2];
	    chart.stacked = Boolean.parseBoolean(args[3]);
	    if (Boolean.parseBoolean(args[4]))
		chart.orientation = PlotOrientation.HORIZONTAL;
	    else
		chart.orientation = PlotOrientation.VERTICAL;
		
	    chart.loadDataFromStdIn(); //	chart.createCategoryTestData();	   	    	    
	    //chart.createCategory2TestData();
	    
	    if (chart.type.equals("bar"))
		chart.createBarChart();
	    else if (chart.type.equals("pie"))
		chart.createPieChart();
	    else if (chart.type.equals("line"))
		chart.createLineChart();
	    else
		throw new Exception("Unknown type '" + chart.type + "'");
	    
	    chart.saveFiles();
	    System.exit(0);
	} catch (Exception ex) {
	    StringWriter sw = new StringWriter();
	    PrintWriter pw = new PrintWriter(sw, true);
	    ex.printStackTrace(pw);
	    pw.flush();
	    sw.flush();
	    
	    System.out.print(sw.toString());
	    
	    System.out.println(ex.toString());
	    System.exit(1);
	}
	
    }
}

