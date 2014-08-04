KT_Help_US_En = [[
<html><body>
<h1>Using KeybindTrainer</h1>
<br/>
<p>KeybindTrainer is an addon to help you learn your keybinds by testing how well you know them. It is usable anywhere and anytime, in or out of combat.</p>
<br/>
<h2>Definitions</h2>
<br/>
<p>Here are a few terms to know when using KeybindTrainer:</p>
<br/>
<h3>Trial</h3>
<p>When KeybindTrainer iterates through a set of keybinds, it is running a |cFFEE4400Trial|r. There are two types of Trials, Default Trials and Custom Trials.</p>
<br/>
<h3>Default Trial</h3>
<p>A |cFFEE4400Default Trial|r is a Trial that is defined by the current state of user action bars at the time the Trial is run.  For example, the Default Trial &quot;All Visible Keybinds&quot; scans visible action slots to determine what to show the user.</p>
<br/>
<h3>Custom Trial</h3>
<p>|cFFEE4400Custom Trials|r are KeybindTrainer Trials built from user input.  They can test any combination of keybinds.  For example, the &quot;Rogue: Cloak and Vanish&quot; Custom Trial tests a common sequence for PvP Rogues. The language used to construct Custom Trials is covered in more detail in a later section.</p>
<br/>
<h3>Action Tuple</h3>
<p>All Trials are made up of sequence of one or more |cFFEE4400Action Tuples|r.  An |cFFEE4400Action Tuple|r is a set of icons displayed all at once by KeybindTrainer.  Each icon represents an . . .</p>
<br/>
<h3>Action</h3>
<p>An |cFFEE4400Action|r is any spell, item, ability, or other action that can be placed on in an action bar slot.</p>
<br/>
<h2>Running a Trial</h2>
<br/>
<p>To run a trial:</p>
<br/>
<p>|cFF3D64FF1. Select the trial you wish to run (for example, &quot;All Visible Keybinds&quot;) from the |r|cFFEE4400Select Trial|r |cFF3D64FFmenu.|r</p>
<br />
<p>|cFF3D64FF2. The |r|cFFEE4400Start Trial|r|cFF3D64FF button will appear in the middle of the Trial area (middle box).  Click it to start the trial.|r</p>
<br />
<p>|cFF3D64FF3. As each Action Tuple appears, press the button(s) corresponding to each Action.|r </p>
<br/>
<p>Unless the |cFFEE4400Run Continuously|r option is checked, the Trial will finish once all Action Tuples have been displayed.  You can also move your mouse out of the Trial area at any time to halt the trial.</p>
<br/>
<h2>Configuring KeybindTrainer</h2>
<br/>
<p>KeybindTrainer supports a variety of options around creating, editing, and running Trials.</p>
<br/>
<h3>Resizing/Moving Addon Window</h3>
<p>To resize KeybindTrainer, click and drag on the bottom right pull handle.  To move any KeybindTrainer window, click and drag its title bar.</p>
<br/>
<h3>Hiding/Showing Addon Window</h3>
<p>To hide the addon window, you can click the top right 'X', click the KeybindTrainer minimap icon, or type |ccFFEE4400/kbt hide|r from the command line.  To show the addon window, you can click the minimap icon, or type |ccFFEE4400/kbt show|r from the command line.</p>
<br/>
<h3>Trial Options</h3>
<p>To have the current Trial loop continuously, select the |cFFEE4400Run Continuously|r option.  To randomize the order Action Tuples are displayed, select |cFFEE4400Randomize Bind Order|r.</p>
<br/>
<h3>Display Options</h3>
<p>KeybindTrainer offers a variety of options for how Actions are displayed during Trials.  Mouse over each option for a tooltip explaining its function.</p>
<br/>
<h2>KeybindTrainer Statistics</h2>
<br/>
<p>KeybindTrainer can collect and display a variety of statistics to measure your keybind performance. Statistics are saved on a per-character basis and can be reset at any time from the Statistics dialog.  The following statistics are available:</p>
<br/>
<h3>Seconds per Bind</h3>
<p>Shows how much time you spent per bind for the last KeybindTrainer trial.</p>
<br/>
<h3>Miss per Bind</h3>
<p>Shows how many misses you had per bind for the last KeybindTrainer trial.</p>
<br/>
<h3>Max Seconds per Bind</h3>
<p>Show the maximum amount time you spent per bind since the last time you cleared your statistics.</p>
<br/>
<h3>Avg Seconds per Bind</h3>
<p>Show how much time you spent per bind on average since the last time you cleared your statistics.</p>
<br/>
<h3>Avg Miss per Bind</h3>
<p>Show how misses you had per bind on average since the last time you cleared your statistics.</p>
<br/>
<p>Descriptions of each graph are also available as tooltips in the |cFFEE4400Keybind Stats|r dialog window.</p>
<br/>
<h2>Slash Commands </h2>
<br/>
<p>The /kbt or /keybindtrainer slash commands have the following arguments: </p>
<br/>
<p> |cFF3D64FF/kbt show|r</p>
<p>Show the KeybindTrainer window.</p>
<br />
<p> |cFF3D64FF/kbt hide|r</p>
<p>Hide the KeybindTrainer window.</p>
<br />
<p> |cFF3D64FF/kbt help|r</p>
<p>Show the KeybindTrainer help window.</p>
<br />
<p> |cFF3D64FF/kbt stats|r</p>
<p>Show the KeybindTrainer statistics window. </p>
<br />
<p> |cFF3D64FF/kbt trial create|r</p>
<p>Shows a window to create a new custom trial.</p>
<br />
<p>|cFF3D64FF/kbt trial edit NAME|r</p>
<p>Requires argument NAME. Shows a window to edit custom trial NAME.</p>
<br/>
<h2>Creating Custom Trials</h2>
<br/>
<p>Custom Trials are easy to create and share.  To add a Custom Trial to KeybindTrainer, click the |cFFEE4400Add Trial|r button (or type |cFF3D64FF/kbt trial create|r) and type or paste the string into the input box.  Click 'Save' when finished.  To save your trial to your Account profile (accessible by all your characters), make sure the |cFFEE4400Save to Profile|r option is selected.</p>
<br/>
<p>A Custom Trial is just a string that tells KeybindTrainer what to display.  These directions are specified using formant called 'JSON'. If you are not familiar with JSON, don't worry--you don't need to be.</p>
<br />
<h3>An Example Custom Trial</h3>
<p>Let's start by going through an example Custom Trial:</p>
<br/>
<p>|cFF3D64FF{&quot;name&quot;:&quot;basic&quot;,&quot;desc&quot;:&quot;An example trial&quot;,&quot;gcd&quot;:1.5,&quot;binds&quot;:[{&quot;action&quot;:&quot;Auto Attack&quot;, &quot;cd&quot;: 1.2}]}|r</p>
<br/>
<p>Let's go through this in more detail:</p>
<br/>
<p>|cFF3D64FF{ }|r</p>
<p>All Custom Trials must start and end with curly brackets ( { } ).</p>
<br/>
<p>|cFF3D64FF&quot;name&quot;:&quot;basic&quot;|r</p>
<p>This is the name of the Custom Trial.  Note that quotes are required both for the key and the value.</p>
<br/>
<p>|cFF3D64FF&quot;desc&quot;:&quot;An example trial&quot;|r</p>
<p>A description for the Custom Trial, used to populate the tooltip in the |cFFEE4400Select Trial|r menu.</p>
<br/>
<p>|cFF3D64FF&quot;gcd&quot;:1.5|r</p>
<p>The GCD time to use for this Custom Trial.  This is the delay used between Actions unless an Action cooldown is specified (see below).</p>
<br/>
<p>|cFF3D64FF&quot;binds&quot;:[]|r</p>
<p>The list of key-bound Actions KeybindTrainer will iterate over for this Trial.  Note that the entire list of Actions must be enclosed in square brackets ( [ ] ).  The label for this section is 'binds'.</p>
<br/>
<p>|cFF3D64FF{&quot;action&quot;:&quot;Auto Attack&quot;, &quot;cd&quot;: 1.2}|r</p>
<p>An Action in this Custom Trial corresponding to a key-bound action on your bar.  The action name is specified by the 'action': section.  This name can be a string (such as 'Auto Attack'), tan integer spell id in the form of 'spell:1234', or an item id in the form of 'item:1234'.  The cooldown for the action is specified by a number following the 'cd' label.  This cooldown overrides the 'gcd' entry specified for the entire Custom Trial.</p> 
<br/>
<h3>Multi-Action Tuples</h3>
<p>Action Tuples in Custom Trials can contain more than one action.  This allows the user to create tests for sequences of keybinds.  A multi-action Tuple is just multiple Actions listed together inside of square brackets ( [ ] ). </p>
<br/>
<p>As an example, consider the &quot;Rogue: Cloak and Vanish&quot; Custom Trial included by default.  The string used to construct this Custom Trial is below:</p>
<br/>
<p>|cFF3D64FF{&quot;name&quot;:&quot;Rogue: Cloak and Vanish&quot;, &quot;gcd&quot;:1.5, &quot;binds&quot;:[{&quot;action&quot;:&quot;Stealth&quot;}, [{&quot;action&quot;:&quot;Cloak of Shadows&quot;, &quot;cd&quot;:0}, {&quot;action&quot;:&quot;Vanish&quot;}] ]}|r</p>
<br/>
<p>Looking at the 'binds' list, there is a single bind Action Tuple for 'Stealth'.  To test 'Cloak of Shadows' and 'Vanish' in sequence, we create a multi-action Action Tuple:</p>
<br/>
<p>|cFF3D64FF[{&quot;action&quot;:&quot;Cloak of Shadows&quot;, &quot;cd&quot;:0}, {&quot;action&quot;:&quot;Vanish&quot;}]|r</p>
<br/>
<p>Here we have two actions in a list surrounded by square brackets ( [ ] ) to create a multi-action Action Tuple.  The bracketed sequence is then included in the 'binds' list with single Actions.  To cancel out the GCD for 'Cloak of Shadows' (which is off the GCD), we set its cooldown ('cd') value to 0.</p>
<br/>
<h3>Custom Trial EBNF</h3>
<p>The Custom Trial language is defined via EBNF as follows. Note: for readability, space means concatenate.</p>
<br/>
<p>  |cFFEE4400trial|r ='{' |cFFEE4400name|r ',' |cFFEE4400binds|r [|cFFEE4400gcd|r ','] [|cFFEE4400desc|r ','] '}' </p>
<p>  |cFFEE4400binds|r = '&quot;binds&quot;:[' |cFFEE4400trial_set|r ']'</p>
<p>  |cFFEE4400trial_set|r = '[' |cFFEE4400action_tuple|r {',' |cFFEE4400action_tuple|r} ']' </p>
<p>  |cFFEE4400action_tuple|r = '{action:' |cFFEE4400action|r [',' |cFFEE4400cooldown|r] '}' </p>
<p>  |cFFEE4400action|r = |cFFEE4400string|r | 'spell:' |cFFEE4400int|r | 'item:' |cFFEE4400int|r</p>
<p>  |cFFEE4400cooldown|r = '&quot;cd&quot;:' |cFFEE4400float|r | '&quot;cd&quot;:&quot;random&quot;'</p> 
<p>  |cFFEE4400gcd|r = '&quot;gcd&quot;:' |cFFEE4400float|r</p>
<p>  |cFFEE4400name|r = '&quot;name&quot;:' |cFFEE4400string|r</p>
<p>  |cFFEE4400desc|r = '&quot;desc&quot;:' |cFFEE4400string|r</p>
<p>  |cFFEE4400string|r = '&quot;' (*any sequence of JSON-legal characters*) '&quot;'</p>
<p>  |cFFEE4400float|r = (*a floating point number*)</p>
<p>  |cFFEE4400int|r = (*an integer*)</p>
<br/>
<h2>Editing Custom Trials</h2>
<br/>
<p>To edit a Custom Trial, select the trial in the |cFFEE4400Select Trial|r menu, and then click |cFFEE4400Edit Trial|r.  Alternatively, type |cFF3D64FF/kbt trial edit NAME|r, where NAME is the name of the trial to edit.  This will bring the trial string up in an edit box, where you can make changes, or copy it for sharing with others.</p>
<br/>
<h2>Deleting Custom Trials</h2>
<br/>
<p>To delete a Custom Trial, select the trial in the |cFFEE4400Select Trial|r menu, and then click |cFFEE4400Edit Trial|r.  Alternatively, type |cFF3D64FF/kbt trial edit NAME|r, where NAME is the name of the trial to edit.  This will open the trial in the edit box.  Once it's open, click |cFFEE4400Delete|r to remove the trial from KeybindTrainer.  Note: this will also remove the Trial from your account profile.</p>
<br/>
<h2>Frequently Asked Questions</h2>
<br/>
<h3>Q: What if I change my keybinds between Trials?</h3>
<p>A: KeybindTrainer scans your keybinds for all action bar slots before each trial is run.  If you change your binds between trials, the next trial you run will reflect your updated binds.</p>
<br/>
<h3>Q: What if I change my keybinds DURING a Trial?</h3>
<p>A: The current trial will stop when you open the WoW keybind configuration window.  When you start your next trial, the new keybind will be picked up by KeybindTrainer.</p>
<br/>
<h3>Q: What if I have multiple binds for the same action?</h3>
<p>A: KeybindTrainer will accept any of the binds for that action during a Trial.</p>
<br/>
<h3>Q: What if a Custom Trial contains a spell that is not on my action bar?</h3>
<p>A: Unfortunately, there is not much KeybindTrainer can do in this case.  The trial will still run, but for unknown spells a '?' icon will be displayed, and any key will be accepted for the bind.</p>
<br/>
<h3>Q: What if a Custom Trial contains an a action name that could mean multiple spells, like 'Feral Charge'?</h3>
<p>A: Action names in Custom Trials are mapped to numeric WoW spell ids by KeybindTrainer.  Some spell ids share the same name, such as 'Feral Charge'.  If action bars contain multiple spells with the same name, KeybindTrainer will prefer the spell id that is bound to a visible action bar at the time the Trial is run. If there is more than one visible bind to actions sharing the same name, or if no binds to actions with identical names are visible, KeybindTrainer will not be able to map the name to a specific bind, and will display a '?' for that action.  Any key will be accepted for the bind when the Trial is run.</p>
<br/>
<h3>Q: What if a Custom Trial contains an action that is on my bar, but does not have a keybind?</h3>
<p>A: The icon for the action will display during the trial, but a '?' will be overlaid because no bind for the action was found.  Any key will be accepted for the bind when the Trial is run.</p>
<br/>
<br/>
</body></html>
   ]]

