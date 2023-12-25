import MuseScore 3.0
import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2
import QtQuick.Dialogs 1.2
import Qt.labs.settings 1.0

//=============================================================================
// MuseScore 3.3+
// MuseScore 4.x
//
// WalkingBass v1.2
// A plugin to compose a reasonable walking bass line, based on Chords
//
// (C) 2023 Phil Kan 
// PitDad Music. All Rights Reserved. 
// With thanks to xxx for initial MuseScore 4 implementation
// 
// Restrictions / Assumptions / Checks
// - 4/4 time
// - Notes are in bass clef, from low E (28) with a 2.5 octave range
// - Quarter notes walking only
// - Requires a score to be open, and some bars with chords to be selected
//
// - If a chord lasts for just one beat, then the root will always be used
// - A pattern consists of 4 or 2 notes, so used for a complete bar, or two beats only
// - Patterns consist of scale notes, plus a few "approach" notes.
// - - a / b indicate to use a semitone approach note above or below the next note
// - - v indicates to a use the fifth of the target chord  (so, should be a b5 for a diminished)
// - Ensure that last note of a pattern is not the same note of the next pattern, as this
//   will really obscure the change of chords  
// - Optionally write the pattern being used below the first note
// - Optionally turn the notes into slashes. Will still play as expected, but appear as a '/'
// - Optionally also include patterns that don't start on the root (e.g. 3-2-1-a)
//
// - todo: Add patterns for 2 bars (8 beats) of the one chord... 
//
// Change History
// v1.0 - initial release
// v1.1 - Fixed height of panel. Added octave jumps for x-x in a pattern
// v1.2 - Added Support for MuseScore 4.x, as a dialog, 
//      - 
//
//=============================================================================

MuseScore 
{
  version: "1.2"
  menuPath: "Plugins.WalkingBass"
  description: "This plug-in generates a walking bass line for given chord changes."
  
  Component.onCompleted : {
    if (mscoreMajorVersion >= 4) {
      title = qsTr("Walking Bass");
      thumbnailName = "WalkingBassIcon.png";
      categoryCode = qsTr("PitDad Tools");
    }
  }
  
  pluginType: mscoreMajorVersion >= 4 ? "dialog" : "dock";
  dockArea: "left";
  implicitHeight: 480;
  implicitWidth: 260;
 

//=============================================================================
// configuration options. These can be set in the UI
  
  property var lowestPitchText: "E1"      // E below C below C below middle C (concert)
  property var lowestPitch: 28
  property var octaveRange: 2.5          // octave range to use
  property var flipPercent: 10            // percentage chance that the next note is 
                                          // not the closest in the octave
                                          
  property bool includePatternText: true  // if true, then the current pattern is written beneath the first note
  property bool useSlashes: false         // if true write notes as stemless slashes. if false, writes as actual notes
  property bool useNonRootPatterns: false // if true use patterns that don't start on the root
  property int  nonRootPercent: 10        // percentage to use non root patterns
  property int  octavesPercent: 50        // when an interval is repeated in a pattern, 
                                          // the percentage chance it will jump an octave
                                          
//=============================================================================
// Layout
//
  GridLayout 
  {
    id: 'walkingBassMainLayout'
    columns: 2
    anchors.fill: parent
    anchors.margins: 10

    Label 
    {
      id: lowestPitchLabel
      text: "Lowest Pitch"
    }
        
    TextField 
    {
      id: lowestPitchField
      placeholderText: lowestPitchText
      horizontalAlignment: TextInput.AlignRight
      Keys.onReturnPressed: isValidLowestNote()
    }
      
    Label 
    {
      id: lowestPitchFieldHelp
      Layout.columnSpan:2
      font.italic: true
      text: "Lowest pitch available, from C0 to B4.\n(Typically E1)"
      bottomPadding: 10
    }

    Label 
    {
      id: octaveRangeLabel
      text: "Octave Range"
    }
        
    TextField 
    {
      id: octaveRangeField
      implicitHeight: 24
      placeholderText: octaveRange
      horizontalAlignment: TextInput.AlignRight
      Keys.onReturnPressed: isValidOctaveRange()
    }
        
    Label 
    {
      id: octaveRangeLabelHelp
      Layout.columnSpan:2
      font.italic: true
      text: "Range in octaves. Typically 2, 2.5 or 3"
      bottomPadding: 10
    }

    Label 
    {
      id: flipPercentLabel
      text: "Flip Percentage"
    }
      
    TextField 
    {
      id: flipPercentField
      implicitHeight: 24
      placeholderText: flipPercent
      horizontalAlignment: TextInput.AlignRight
      Keys.onReturnPressed: isValidFlipPercent()
    }
      
    Label 
    {
      id: flipPercentLabelHelp
      Layout.columnSpan: 2
      font.italic: true
      text: "Percentage that a 3rd, 4th, 5th, or 6th\nis furthest not closest"
      bottomPadding: 10
    }

    CheckBox 
    {
      id: includePatternTextCheck
      Layout.columnSpan: 2
      text: "Patterns"
      checked: includePatternText
    }
      
    Label 
    {
      id: includePatternTextHelp
      Layout.columnSpan:2
      font.italic: true
      text: "Include the pattern text below the first note"
      bottomPadding: 10
    }
    
    CheckBox 
    {
      id: useSlashesCheck
      Layout.columnSpan:2
      text: "Slashes"
      checked: useSlashes
    }
      
    Label 
    {
      id: useSlashesHelp
      font.italic: true
      bottomPadding: 10
      text: "Use slashes instead of notes"
      Layout.columnSpan:2
    }

    Label 
    {
      id: useNonRootPatternslabel
      text: "Use non-root patterns (%)"
    }        
             
    TextField 
    {
      id: nonRootPercentField
      placeholderText: nonRootPercent
      horizontalAlignment: TextInput.AlignRight
      Keys.onReturnPressed: isValidNonRootPercent()
    }
      
    Label
    {
      id: octavesPercentLabel
      text: "Repeat-note Octaves (%)"
    }        
             
    TextField 
    {
      id: octavesPercentField
      placeholderText: octavesPercent
      horizontalAlignment: TextInput.AlignRight
      Keys.onReturnPressed: isValidOctavesPercent()
    }
        
    Button 
    {
      id: applyButton
      Layout.columnSpan: 2
      text: qsTranslate("PrefsDialogBase", "Apply")
      onClicked: applyBassLine()
    }
        
    Label 
    {
      id: errorLabel
      visible: false
      Layout.columnSpan:2
    }
  }
    
//=============================================================================

  function isValidLowestNote()
  {
    if (!(/^[A-G]{1}(b|#)?[0-4]{1}$/.test(lowestPitchField.text)) ) 
    {
      inputError.text = "Lowest pitch must be a valid note & octave. e.g. E3"
      inputError.open();
    }
   
    parseLowestNote();
  }
 
//=============================================================================

  function parseLowestNote()
  {     
    var idx = 0;
    var adjustPitch = 0;
   
    var root = lowestPitchField.text[idx].toUpperCase();
    idx++;

    // could be #or b as well.. 
    if ('#b'.includes(lowestPitchField.text[idx]))
    { 
      adjustPitch = lowestPitchField.text[idx] == "b" ? -1 : 1; 
      idx++; 
    } 

    var octave = parseInt(lowestPitchField.text[idx]);
    lowestPitch = c0 + (12 * octave) + letterToSemitone[root] + adjustPitch;
  }
    
//=============================================================================

  function isValidOctaveRange()
  {
    if (!(/^(\d)*(\.)?([0-9]{1})?$/.test(octaveRangeField.text)) ) 
    {
      displayError("Octave Range must be a number from 0 to 4.");
      return false;
    }

    octaveRange = parseFloat(octaveRangeField.text);
   
    if (octaveRange > 4)
    { 
      displayError("Octave Range must be a number from 0 to 4.");
      return false;
    }
   
    return true;
  }
    
  function isValidFlipPercent()
  {
    if (! (/^\d+$/.test(flipPercentField.text) )) 
    {
     displayError("Not a valid Non-roots percentage.\nUse a whole number between 0 and 100 ");
     return false;
    }

    flipPercent = parseInt(flipPercentField.text);
   
    if (flipPercent < 0 || flipPercent > 100)
    {
      displayError("Not a valid Non-roots percentage.\nUse a whole number between 0 and 100 ");
      return false;
    }
   
    return true;
  }
   
   
  function isValidNonRootPercent()
  {
    if (! (/^\d+$/.test(nonRootPercentField.text)) ) 
    {
      displayError("Not a valid Non-roots percentage.\nUse a whole number between 0 and 100 ");
      return false;
    } 

    nonRootPercent = parseInt(nonRootPercentField.text);
   
    if (nonRootPercent < 0 || nonRootPercent > 100)
    {
      displayError("Not a valid Non-roots percentage.\nUse a whole number between 0 and 100 ");
      return false;
    }
   
    return true;
  }

  function isValidOctavesPercent()
  {
    if (! (/^\d+$/.test(octavesPercentField.text)) ) 
    {
      displayError("Not a valid flip percentage.\nUse a whole number between 0 and 100 ");
      return false;
    }
   
    octavesPercent = parseInt(octavesPercentField.text);
   
    if (octavesPercent < 0 || octavesPercent > 100) 
    {
      displayError("Not a valid flip percentage.\nUse a whole number between 0 and 100 ");
      return false;
    }
   
    return true;
  }
   
//=============================================================================

  function displayError(message)
  {
    inputError.text = message;
    inputError.open();
  }

  MessageDialog 
  {
    id: inputError
    visible: false
    title: "Numeric input error"
    text: "Lowest Note and Range must be numeric values"
    onAccepted: {
      close();
    }
  }

//=============================================================================

  MessageDialog 
  {
    id: versionError
    visible: false
    title: qsTr("Unsupported MuseScore Version")
    text: qsTr("This plugin needs MuseScore 3.3 or later")
    onAccepted: {
      Qt.quit() 
    }
  }
  
//=============================================================================

  // internal globals
  property int highestPitch: lowestPitch + (12 * octaveRange);

  // based on the major scale
  property var intervalToSemitone: {'1':0, '2':2, '3':4, '4':5, '5':7, '6':9, '7':11};
    
  // Now based on C0
  property var letterToSemitone: {'C': 0, 'D': 2, 'E': 4, 'F': 5, 'G': 7, 'A': 9, 'B': 11};
  property var c0: 12               // midi for C0

  // [b]elow, [a]bove [v]fifth
  property var approachSemitones: { "b": -1, "a": 1, "v": 7, };

  property var patterns2:
  [
    // doubling up on some root & approach note versions so they have a greater chance of getting used
    "1-1", "1-3", "1-5", "1-6", "1-7",
           "1-3", "1-5",        "1-7",
           "1-3", "1-5",        "1-7",
    "1-a", "1-b", "1-v",
    "1-a", "1-b", "1-v",
    "1-a", "1-b", "1-v", 
  ]

  property var patterns2NonRoot:
  [
    "3-1", "3-5", "3-a", "3-b", "3-v", 
    "5-1", "5-3", "5-a", "5-b", "5-v",
  ]
  
  property var patterns:
  [ 
  
    "1-a-3-1", "1-a-3-5", "1-a-3-a", "1-a-3-b", "1-a-3-v", 
    "1-b-2-1", "1-b-2-3", "1-b-2-a", "1-b-2-b", "1-b-2-v",
    "1-1-3-5", "1-1-3-a", "1-1-3-b", "1-1-3-v",
    "1-1-5-1", "1-1-5-3", "1-1-5-5", "1-1-5-a", "1-1-5-b", "1-1-5-v",
    "1-2-3-1", "1-2-3-5", "1-2-3-a", "1-2-3-b", "1-2-3-v",

    "1-3-1-5", "1-3-1-7", "1-3-1-a", "1-3-1-b", "1-3-1-v",
    "1-3-5-1", "1-3-5-7", "1-3-5-a", "1-3-5-b", "1-3-5-v",
    "1-3-6-1", "1-3-6-7", "1-3-6-a", "1-3-6-b", "1-3-6-v",
  
    "1-5-1-5", "1-5-1-3", "1-5-1-a", "1-5-1-b", "1-5-1-v",
    "1-5-3-1", "1-5-3-5", "1-5-3-a", "1-5-3-b", "1-5-3-v",
    "1-5-7-1", "1-5-7-5", "1-5-7-a", "1-5-7-b", "1-5-7-v",
    "1-6-5-3", "1-6-5-6", "1-6-5-a", "1-6-5-b", "1-6-5-v",
    "1-6-7-1", "1-6-7-3", "1-6-7-6", "1-6-7-5", "1-6-7-1", "1-6-7-b", "1-6-7-v",
    "1-7-6-7", "1-7-6-5", "1-7-6-3", "1-7-6-1", "1-7-6-a", "1-7-6-b", "1-7-6-v", 
    "1-7-5-7", "1-7-5-6", "1-7-5-3", "1-7-5-a", "1-7-5-b", "1-7-5-v", 
  ]
  
  property var patternsNonRoot:
  [
    "3-2-1-1", "3-2-1-5", "3-2-1-7", "3-2-1-a", "3-2-1-b", "3-2-1-v",
    "3-5-1-1", "3-5-1-5", "3-5-1-7", "3-5-1-a", "3-5-1-b", "3-5-1-v",
    "3-7-1-1", "3-7-1-5", "3-7-1-7", "3-7-1-a", "3-7-1-b", "3-7-1-v", 
    "3-a-1-1", "3-a-1-5", "3-a-1-7", "3-a-1-a", "3-a-1-b", "3-a-1-v", 
    "3-b-1-1", "3-b-1-5", "3-b-1-7", "3-b-1-a", "3-b-1-b", "3-b-1-v",
    "5-3-1-1", "5-3-1-5", "5-3-1-7", "5-3-1-a", "5-3-1-b", "5-3-1-v",
  ]  
  
  property int quarterNoteDuration: division;

  property int previousPitch: -1;
  property var approachPattern: "";
  property var approachTick: 0;  
  
  property var notes: [];

//=============================================================================
// some faux enums as this seems to be best way to achieve this in qml
 
  QtObject 
  {
    id: triadType

    property int major: 0
    property int minor: 1
    property int diminshed: 2
    property int augmented: 3
    property int dominant: 4
    property int halfDiminished: 5
  }

//=============================================================================

  function applyBassLine()
  {
    errorLabel.text = "";
    errorLabel.visible = false;
  
    var cursor = getCursor();
    
    if (!cursor.segment )        // no selection
    { 
      console.log("Error: Nothing is selected.")
      errorLabel.text = "Error: Nothing is selected.\nPlease select one staff of bars with chords";
      errorLabel.visible = true;
      return;
    }
    
    if (curScore.selection.endStaff - curScore.selection.startStaff > 1)
    {
      console.log("More than one staff selected")    
      errorLabel.text = "Error: More than one staff is selected\nPlease select only one staff, with chords";
      errorLabel.visible = true;
      return;
    }
    
    if (!isValidOctaveRange()) return;
    if (!isValidOctavesPercent()) return;
    if (!isValidNonRootPercent()) return;
    
    previousPitch = -1;
    approachPattern = "";
    approachTick = 0;  

    parseLowestNote();
    
    octaveRange = parseFloat(octaveRangeField.text);
    highestPitch = lowestPitch + (12 * octaveRange);   
    flipPercent = parseInt(flipPercentField.text);

    includePatternText = includePatternTextCheck.checked;
    useSlashes = useSlashesCheck.checked;
    nonRootPercent = parseInt(nonRootPercentField.text);
    
    // a random starting point
    previousPitch = lowestPitch + Math.floor(Math.random() * (highestPitch - lowestPitch));
    
    curScore.startCmd()
    
    addBassLine(cursor);

    curScore.endCmd()

console.log("----------------------------------------");    
  }

//=============================================================================

  // Helper function for determining extensions 
  // returns true if the provided character is a number (1-9)
  // 0 is excluded, as that is used to indicate half diminished, and not used in extensions
  function isNumber(ch)
  {
    // and is NOT used any extensions.. 
    return "123456789".includes(ch);
  }

//=============================================================================

  // parse a provided chord into its component parts
  // root: the root note of the chord
  // triad: the chord quality. One of the triadType values
  // extensions: a list of the extensions to the chord (e.g. #5, b9, etc)
  // bass: if its a slash chord, the bass note (after the slash)
  function parseChord(chord)
  {
    // letter
    var idx = 0;
    if ("()".includes(chord[idx])) idx++; // just ignore brackets!

    console.log(idx + " - " + chord + " - " + chord[idx])

    var root = chord[idx].toUpperCase();
    idx++;

    // could be #or b as well.. 
    if ('#b'.includes(chord[idx]))
    { 
      root += chord[idx]; 
      idx++; 
    } 
   
    // triadType
    var triad = -1;
    var triadWord = "";
    while ( (idx < chord.length) && !isNumber(chord[idx]) && chord[idx] != "/")  
    {
          triadWord = triadWord + chord[idx++]
    }

    switch (triadWord)
    {
      case "":                                    // there is no triad type - just nothing, or straight to numbers
        if (idx == chord.length) {
          triad =  triadType.major;               // just letter, so major
        }
        else if (chord[idx] == "6") 
        {
          triad =  triadType.major;               // 6, or 6/9 == major
          idx++;
       } else 
          triad =  triadType.dominant;            // anything else is dominant = 7, 9, 13 etc. 
        break;
//
      case "^":     triad = triadType.major;      break;
      case "∆":     triad = triadType.major;      break;
      case "Major": triad = triadType.major;      break;
      case "major": triad = triadType.major;      break;
      case "Maj":   triad = triadType.major;      break;
      case "maj":   triad = triadType.major;      break;
      case "Ma":    triad = triadType.major;      break;
      case "ma":    triad = triadType.major;      break;
      case "M":     triad = triadType.major;      break;
      case "j":     triad = triadType.major;      break;
//
      case "minor": triad = triadType.minor;      break;
      case "min":   triad = triadType.minor;      break;
      case "mi":    triad = triadType.minor;      break;
      case "m":     triad = triadType.minor;      break;
      case "-":     triad = triadType.minor;      break;
      case "-":     triad = triadType.minor;      break;     
//
      case "o":     triad = triadType.diminished; break;
      case "O":     triad = triadType.diminished; break;
      case "dim":   triad = triadType.diminished; break;
      case "°":     triad = triadType.diminished; break;
//       
      case "0":     triad = triadType.halfDiminished; break;
      case "ø":     triad = triadType.halfDiminished; break;
//      
      case "+":     triad = triadType.augmented;  break;
      case "aug":   triad = triadType.augmented;  break;
//      
    }
    
    // everything else is extensions.. until possibly a different bass note
    var extensionWord = "";
    var extensions = [];

    while ( (idx < chord.length) && (chord[idx] != "/") ) 
    {
      if ("()".includes(extensionWord[c]))  continue; // just ignore it!
      extensionWord = extensionWord + chord[idx++]
    }
    
    var ex = "";
    if (extensionWord.includes("alt")) // its an altered chord, we'll use a 7#5#9
    {
      extensionWord = "7#5#9";
      triad = triadType.dominant;   // just to be sure!
    }
    
    for (var c in extensionWord)
    {     
      if ("()".includes(extensionWord[c]))  continue; // just ignore it!
      if ("#b".includes(extensionWord[c]))         // if its a sharp or flat, that's the end of the current extension
      {
        extensions.push(ex);
        ex = extensionWord[c];
        continue;
      }
      ex = ex + extensionWord[c];
    }
    
    extensions.push(ex);
       
    // we have a slash chord! the rest of the chordSymbol will be the bass note
    var bassWord = "";
   
    if (chord[idx] == "/")
    {
      idx++;
      while ( idx < chord.length) 
      {
        bassWord = bassWord + chord[idx++]
      }
    }
    
    var bass = bassWord;
    
    return {root: root, triad: triad, extensions: extensions, bass: bass}
  }
       
//=============================================================================
 
  // get a random pattern to use, based on the number of quarter notes required
  function getPattern(quarterNotes)
  {
    var nonRoot = (Math.random() * 100) < nonRootPercent
    
    if (quarterNotes == 1)
    {
      return "1";
    }
    
    if (quarterNotes == 2)
    {
      
      return nonRoot ? 
        patterns2NonRoot[Math.floor(Math.random() * patterns2NonRoot.length)] :
        patterns2[Math.floor(Math.random() * patterns2.length)] 
    }
    
    // for anything else, just return 4 at a time
    return nonRoot ?
      patternsNonRoot[Math.floor(Math.random() * patternsNonRoot.length)] :
      patterns[Math.floor(Math.random() * patterns.length)];
  }
      
//=============================================================================

  // add a basseline - this is where it all starts!  
  function addBassLine(cursor)
  {
      var endTick = getEndTick(cursor);
      
      cursor.rewind(Cursor.SELECTION_START);
      var segment = curScore.selection.startSegment
      var selectedStaff = curScore.selection.startStaff;

      var chordSymbols = findAllChordSymbols(segment, selectedStaff, endTick);
      chordSymbols.sort(compareChordSymbols);
      
      previousPitch = -1;

      cursor.setDuration(1, 4);
      for (var c in chordSymbols)
      {
        addNotes(cursor, chordSymbols[c]);
      }    
  }
  
//=============================================================================
// Sorting function for chord symbol structures, to sort by the tick value
// this helps when the user has selected a bunch of bars in reverse order

  function compareChordSymbols(chord1, chord2)
  {
    if ( chord1.tick < chord2.tick ){
      return -1;
    }
    
    if ( chord1.tick > chord2.tick){
      return 1;
    } 
    
    return 0;
  }
  

//=============================================================================
// Search the current score for all the chord symbols in the current staff / track
// Returns an array of score chord symbol objects like {tick: 1440, duration: 960, text: "Db7"}.

  function findAllChordSymbols(segment, staff, endTick) 
  {
    var chords = {};
    
    while (segment && (segment.tick < endTick)) 
    {
        var annotations = segment.annotations;        
        
        for (var a in annotations) {
            
            var annotation = annotations[a];
            if ((annotation.name == "Harmony") && (annotation.track / 4 == staff)) 
            {
              chords[segment.tick] = {tick: segment.tick, text: annotation.text, };
            }
            
        }
        segment = segment.next;
    }

    // Calculate the duration of each chord = start time of next chord - start time of this chord.
    // Also, copy all the chords to an Array, we no longer need them to be in an Object.
    var result = [];
    for (var i in chords) 
    {
        var chord = chords[i];
        if (result.length > 0) 
        {
          result[result.length - 1].duration = chord.tick - result[result.length - 1].tick;
        }
        result.push(chord);
    }
    
    if (result.length > 0) 
    {
        var lastItem = result[result.length - 1];
        lastItem.duration = endTick - lastItem.tick;
    }
    
    return result;
}

  
//=============================================================================

  // add notes at the current cursor.
  // chordText: the full text of the chord to use  (e.g. "Cm7b9/G")
  // quarterNotes: the number of quarter notes to add
  //  chordSymbols[c].text, chordSymbols[c].duration / quarterNoteDuration 
  function addNotes(cursor, chordSymbol)
  {
    cursor.rewindToTick(chordSymbol.tick);

    var chord = parseChord(chordSymbol.text);
    var rootPitch = getLetterPitch(chord.root);
    var quarterNotes = chordSymbol.duration / quarterNoteDuration;
    
    // ensure we do enough quarterNotes    
    for (var i = 0; i < quarterNotes; i++) 
    {
      // Get a random pattern to use, either in part or in whole
      var pattern = getPattern(quarterNotes);

console.log(chordSymbol.text + ":" 
      + (chordSymbol.text.length < 3 ? "\t" : "") + "\t"
      + pattern);

      // for each note in the pattern      
      for (var j = 0; j < pattern.length; j++)
      {
        // ignore the spacers in the pattern
        if (pattern[j] == "-") continue;
        
        // if the pattern note is an approach note, then save that information for later
        // and make it look like we've added a note it by advancing the number of notes (i)
        if (("abv").includes(pattern[j])) 
        {
            approachPattern = pattern[j]
            approachTick = cursor.tick;
            cursor.next()
            i++;
            continue;
        }
        
        var notePitch = -1;
        if (j == 0 && chord.bass != "")            
        {
          // a specified bass note will be used as the first note
          notePitch = getLetterPitch(chord.bass)
        } 
        else 
        {
          notePitch = getIntervalPitch(rootPitch, pattern[j]);
        
          // adjust the tones based on the chord quality
          notePitch = adjustPitchToChordQuality(notePitch, pattern[j], chord.triad, cursor)
          notePitch = adjustForExtensions(notePitch, pattern[j], chord.extensions)
        }
        
        // adjust the note octave so its the closest one to the previous note
        notePitch = adjustPitchToBeClosestToPreviousPitch(notePitch, previousPitch)

        // if this is the first note in the pattern, and there is no approach note
        // then avoid duplicating the previous pitch
        // this works by moving the previous pitch up or down
        //if (j == 0 && (approachPattern == "")) 
        //{
        //  avoidFirstNoteIdenticalToLastNote(notePitch, previousPitch, cursor)
        //}

        // if we're duplicating a note, then, 
        // if this is the first note of the pattern, then adjust the last note of last pattern
        // otherwise scale it an octave as specified in the options
        if (notePitch == previousPitch)
        {
          if (j == 0) 
          {
            avoidFirstNoteIdenticalToLastNote(notePitch, previousPitch, cursor)
          }
          else if ((Math.random() * 100) < octavesPercent) 
          {
            notePitch += (Math.random() * 100) < 50 ? -12 : 12;
          }
        }
        
        // make sure we haven't gone too far!
        notePitch = ensurePitchIsInRange(notePitch)
        
        // handle the pending approach note
        // this might change the actual note, if its at the top or bottom of the range
        if (approachPattern != "") 
        {
          notePitch = insertApproachNote (notePitch, chord.triad, cursor)
          approachPattern = "";
        }

        // finally insert the current actual note!
        var noteTick = cursor.tick;
        addNote(cursor, notePitch)
          
        // add the pattern text to the first note
        if (j == 0 && includePatternText) 
        {
            addPatternTextToPreviousNote(cursor, pattern)
        }
        
        notes.push(notePitch);
        
        previousPitch = notePitch;
        
        // advance the note counter
        i++;
      }  
    }
  }
  
//=============================================================================
  
  // get a list of the pitches in the given key signature
  // the list is the pitch values in the range from 0-11
  // where 0 is C, 1 is C# etc. 
  function pitchesInKey(keySig)
  {
    // map the keySignature (number of flats or sharps) to a pitch note in the 0-11 pitch range
    var root = 0;
    if (keySig < 0) root = (keySig*(-5)) % 12;
    if (keySig > 0) root = (keySig * 7) % 12;

    // get the relevant pitches of the major scale    
    var notes = [];
    for (var i = 1; i < 8; i++)
    {
      var note = (12 + root + intervalToSemitone[i]) % 12; 
      notes.push(note)
    }
    
    return notes;
  }
  
//=============================================================================

  // adjust the given pitch to the chord quality provided
  // pitch: the starting pitch to use  (e.g. 47 (== B2)
  // interval: the interval the pitch is supposed to be in the chord (e.g. 3, the third)
  // triad: the type of triad (eg Minor).   
  // In this case, the 47 would be adjusted to a 46, so it become a Bb, which is the _minor_ 3rd
  function adjustPitchToChordQuality(pitch, interval, triad, keySig)
  {
      var newPitch = pitch;
      switch (triad)
        {
            case triadType.major:
              break;
              
            case triadType.minor:             // assume dorian - flat 3, 7
              if (("37").includes(interval)) newPitch--
              break;
                  
            case triadType.diminished:        // assume HW scale... 1 b2 b3, #4, b5, 6, (bb7)
              if (("2357").includes(interval)) newPitch--;
              if (interval == "7") pitch--;              // double flat == 6!
              if (interval == "4") pitch++;   
              break;
                  
            case triadType.augmented:         // assume whole tone scale 1, 2, 3, #4 #5, #6 7
              if (("2456").includes(interval)) newPitch++;
              break;

            case triadType.dominant:
              if (interval == "7") newPitch--;
              break;
              
            case triadType.halfDiminished:    // assume locrian - flat 2, 3, 5, 6, 7
              if (("23567").includes(interval)) newPitch--;
              break;
        }
      
      return newPitch;
  }
  
//=============================================================================

  // adjust the given pitch according to the extensions of the chord
  // e.g. if the chord is a C7b9, and we have a 2nd, then it should become a b2
  function adjustForExtensions(pitch, interval, extensions)
  {
      var flat = true;
      var extensionInterval = 0;
      for (var ex in extensions)
      {
        if (extensions[ex].length < 2) continue;               // its got to be at least 2 chars (eg. #5, not just 7)
        
        flat = (extensions[ex][0] == "b");                     // if not, then its a sharp
        extensionInterval = extensions[ex].substring(1);       // get the actual extension
        if (extensionInterval > 8) extensionInterval -= 7;     // 9->2, 11-> 4, 13->6
        if (extensionInterval <=0) continue;
        
        if (extensionInterval == interval)
        {
          pitch += flat ? -1 : 1;
          break;
        }
      }
      
      return pitch;
  }
  
//=============================================================================

  // adjust the current pitch so its in the closest octave position to the
  // previous pitch. This helps to ensure a smoothly moving  bass line
  // e.g D->F should move a minor 3rd up, rather than a major 6th down
  // If the distance between the notes is a 4th, a tritone, or a 5th, 
  // then randomly flip the octave, because it kind of doesn't matter that much.
  function adjustPitchToBeClosestToPreviousPitch(notePitch, previousPitch)
  {
    var newPitch = notePitch;

    if (previousPitch <= 0) 
    {
      // our very first note! Let's make it a good one!
      // choose a random octave to start in - but not too high!
      newPitch += Math.floor(Math.random() * octaveRange - 1) * 12     
      return newPitch;
    }

    // new note is more than a 5th below, so raise it up
    if (previousPitch - newPitch > 7)
    {
      while (previousPitch - newPitch > 7) newPitch += 12;
    }

    // new note is more than a 5th above, so push it down
    if (newPitch - previousPitch > 7)
    {
      while (newPitch - previousPitch > 7) newPitch -= 12;
    }
    
    // if the new pitch is from a minor third to a sixth, randomly flip the interval
    var diff = Math.abs(newPitch - previousPitch);
    if ((3 <= diff && diff <= 9) && ((Math.random() * 100) < flipPercent))
    {
      newPitch += (newPitch < previousPitch) ? 12 : -12
    }
      
    return newPitch;  
  }
  
//=============================================================================

  // adjust the given pitch to ensure its in the provided range
  // by pushing up or down octaves
  function ensurePitchIsInRange(notePitch)
  {
        while (highestPitch < notePitch) notePitch -=12;
        while (notePitch < lowestPitch) notePitch += 12;
        
        return notePitch;
  }
  
//=============================================================================

  // ensure the last note of one pattern is not the same as the first note of the next pattern
  // this works by moving the previous pitch randomly up or down a semitone
  // it might result in the previous pitch being the same as the pitch before that
  // but that's more ok. 
  function avoidFirstNoteIdenticalToLastNote(notePitch, previousPitch, cursor) 
  {
        // if this is the first note in the pattern, and there isn't an approach pitch
        // and its the same pitch as the previous note, then adjust the previous note
        if (previousPitch == notePitch)
        {
            var upOrDown = Math.floor(Math.random() * 2); 
            if(upOrDown == 0) upOrDown = -1;                // so either -1 or 1
            
            cursor.rewindToTick(cursor.tick - quarterNoteDuration);
            addNote(cursor, previousPitch + upOrDown);      // replaces the previous note
        }
  }
  
//=============================================================================

  // modify the previous note to be the current approachPattern
  // the targetTriad is used to ensure that any 'v' approaches follow the adjustments
  // of the chord being moved to (e.g a flat 5 is used to approach a half-diminished)
  function insertApproachNote(notePitch, targetTriad, cursor)
  {
      if (approachPattern == "") return;

      var approachNotePitch = notePitch + approachSemitones[approachPattern];
      
      var currentCursorTick = cursor.tick;
      cursor.rewind(cursor.tick - quarterNoteDuration);
      
      var noteBeforeApproachPitch = notes[notes.length-1];
      
      cursor.rewind(currentCursorTick);
      
      // if approach is a 'v' - the Fifth of the target chord
      // we might need to adjust it to be a flat 5 (half dim, diminished), or sharp 5 (augmented)
      if (approachPattern == "v")  
      {
        approachNotePitch = adjustPitchToChordQuality(approachNotePitch, "5", targetTriad, cursor);
      }
      
      approachNotePitch = adjustPitchToBeClosestToPreviousPitch(approachNotePitch, noteBeforeApproachPitch)
      notePitch = adjustPitchToBeClosestToPreviousPitch(notePitch, approachNotePitch)
      
      // if we're trying to approach the lowest note from below, just push them both up the octave
      if (approachNotePitch < lowestPitch || notePitch < lowestPitch)
      {
        approachNotePitch += 12
        notePitch += 12;
      }

      // likewise for trying to approach the highestPitch from above
      if (approachNotePitch > highestPitch || notePitch > highestPitch)
      {
        approachNotePitch -= 12
        notePitch -= 12;
      }

      cursor.rewindToTick(approachTick);
      addNote(cursor, approachNotePitch);
      notes.push(approachNotePitch);

      approachPattern = "";  // no approachPitch needed anymore
      approachTick = -1;
      
      return notePitch;
  }
  
  
//=============================================================================

  // given a note letter (e.g. "E"), return the lowest pitch in range. 
  function getLetterPitch(letter)
  {
    var pitch = letterToSemitone[letter[0]];
    
    // adjust for b or #
    if (letter.length > 1) 
    {
      pitch += (letter[1] == "b") ?  -1 : 1    // if its not a flat, its a sharp
    }

    while (pitch < lowestPitch) { pitch += 12; }
    
    return pitch;     
  }
  
//=============================================================================

  function getIntervalPitch(rootPitch, interval)
  {  
    return rootPitch + intervalToSemitone[interval];
  }
  
//=============================================================================

  // helper to add notes
  function addNote(cursor, pitch)
  {
    var beforeTick = cursor.tick;
    cursor.addNote(pitch, false);
      
    // transform it into a slash if required
    if (useSlashes)
    {
      var cursorTick = cursor.tick;
      cursor.rewindToTick(beforeTick);
      
      if (cursor.element.type == Element.CHORD) 
      {
        cursor.element.noStem = true;
            
        var notes = cursor.element.notes;
        for (var i = 0; i < notes.length; i++)
        {
          var note = notes[i];
        
          note.fixed = true;
          note.fixedLine = 4;
          note.headScheme = NoteHeadScheme.HEAD_AUTO
          note.headGroup = NoteHeadGroup.HEAD_SLASH;
          note.headType = NoteHeadType.HEAD_AUTO
        }
      }
      cursor.rewindToTick(cursorTick);
    }
  }
  
//=============================================================================
  function addPatternTextToPreviousNote(cursor, pattern)
  {
  
    var cursorTick = cursor.tick;
        
    // go back to the note we just added, and add the text
    cursor.rewindToTick(cursorTick - quarterNoteDuration);
    var text  = newElement(Element.STAFF_TEXT)
    text.text = pattern;
    text.placement = Placement.BELOW
    cursor.add(text);
    cursor.rewindToTick(cursorTick);
  }

//=============================================================================

  function getCursor()
  {
    var cursor = curScore.newCursor()
    cursor.staffIdx = 0;
    cursor.voice = 0;
    cursor.rewind(Cursor.SELECTION_START);
    
    return cursor;
  }

//=============================================================================

  function getEndTick(cursor)
  {
    cursor.rewind(Cursor.SELECTION_END);
    var endStaff = cursor.staffIdx;
    
    var endTick;
    
    if (cursor.tick == 0) {
      // this happens when the selection includes  the last measure of the score.
      // rewind(Cursor.SELECTION_END) goes behind the last segment (where there's none) and sets tick=0
      endTick = curScore.lastSegment.tick;
    } else {
      endTick = cursor.tick;
    }
    
    cursor.rewind(Cursor.SELECTION_START);
    return endTick;
  }
  
//=============================================================================

  function setDefaults()
  {
    previousPitch = -1;
    approachPattern = "";
    approachTick = 0; 
    
    lowestPitchField.text = lowestPitchText;
    octaveRangeField.text = octaveRange;
    flipPercentField.text = flipPercent;
    
    includePatternTextCheck.checked = includePatternText;
    useSlashesCheck.checked = useSlashes;
    nonRootPercentField.text = nonRootPercent;
    octavesPercentField.text = octavesPercent;
  }  

//=============================================================================

  onRun: 
  {
    if (!   // MS 3.3 & higher, and MS 4.x are all supported. 
      ((mscoreMajorVersion == 3 && mscoreMinorVersion >= 3) ||
       (mscoreMajorVersion == 4)
       ))
    {
      versionError.open()
      
      if (typeof(quit) === 'undefined') 
      { 
        Qt.quit() 
      }
      else 
      { 
        quit() 
      }
      
      return;
    }
    
    console.log("WalkingBass docked plugin onRun.")
    
    setDefaults();
  }
}
