// BASED FROM THE COLDBOX "CONTROLLER.CFC" COMMAND - https://github.com/Ortus-Solutions/commandbox/tree/master/src/cfml/commands/coldbox/create
/**
* Create a new controller in an existing FW/1 application.
* .
* {code:bash}
* fw1 create controller myController 
* {code}
* .
* By default, only the "default" action is generated but can be overridden to
* include a list of actions.
* .
* {code:bash}
* fw1 create controller myController list,add,edit,delete
* {code}
* .
* By default, the controller will be created in /controllers but can be
* overridden.
* .
* {code:bash}
* fw1 create controller myController default my/directory
* {code}
* .
* Views are auto-generated in a /views folder by default but can be overridden.
* .
* {code:bash}
* fw1 create controller myController default controllers false
* {code}
* .
* The directory for the views can be overridden as well.
* .
* {code:bash}
* fw1 create controller myController default controllers true my/views
* {code}
* .
* Once created, the controller can be opened in your default editor by
* setting the "open" param to true.
* .
* {code:bash}
* fw1 create controller myController --open
* {code}
*/
component displayname="FW/1 Create Controller Command"
	excludeFromHelp=false
{
	/**
	* @name.hint Name of the controller to create.
	* @actions.hint A comma-delimited list of actions to generate
	* @directory.hint The base directory to create your controller in. Defaults to 'controllers'.
	* @views.hint Generate a view for each action.
	* @viewsDirectory.hint The directory where your views are stored.
	* @open.hint Open the controller once generated.
	*/
	public void function run( 	
		required string name,
		string actions = "default",
		string directory = "controllers",
		boolean views = true,
		string viewsDirectory = "views",
		boolean open = false
	) {
		// This will make each directory canonical and absolute
		arguments.directory = fileSystemUtil.resolvePath( arguments.directory );
		arguments.viewsDirectory = fileSystemUtil.resolvePath( arguments.viewsDirectory );
		// Validate directory
		if ( !directoryExists( arguments.directory ) ) { directoryCreate( arguments.directory ); }
		// Allow dot-delimited paths
		arguments.name = arguments.name.replace( ".", "/", "all" );
		// This helps readability so the success messages aren't up against the previous command line
		print.line();
		// Generate controller with actions passed
		var controllerContent = scaffoldController( arguments.name, arguments.actions.listToArray() );
		var controllerPath = "#arguments.directory#/#arguments.name#.cfc";
		// Create dir if it doesn't exist
		directoryCreate( getDirectoryFromPath( controllerPath ), true, true );
		// Create files
		file action="write" file="#controllerPath#" mode="777" output="#controllerContent#";
		print.greenLine( "Created #controllerPath#" );
		// Create views?
		if ( arguments.views ) {
			arguments.actions.listToArray().each(function( action ) {
				var viewPath = viewsDirectory & "/" & name & "/" & action & ".cfm";
				// Create dir if it doesn't exist
				directoryCreate( getDirectoryFromPath( viewPath ), true, true );
				// Create view
				fileWrite( viewPath, "<cfoutput>#cr##chr(9)#<h1>#name#.#action#</h1>#cr#</cfoutput>" );
				print.greenLine( "Created " & viewsDirectory & "/" & name & "/" & action & ".cfm" );
			});
		}
		// Open file
		if ( arguments.open ){ openPath( controllerPath ); }	
	}

	private string function scaffoldController(
		required string name,
		array actions = ["default"]
	) {
		savecontent variable="controller" {
			writeOutput( 'component displayname="#arguments.name# controller" {' & cr );
			arguments.actions.each(function( action, index ) {
				writeOutput( chr(9) & "public void function #action#(struct rc = {}) {" & cr );
				writeOutput( chr(9) & chr(9) & cr );
				writeOutput( chr(9) & "}" );
				if ( index != actions.len() ) { writeOutput( cr & cr ) }
			});
			writeOutput( cr & "}" );
		}

		return controller;
	}
}