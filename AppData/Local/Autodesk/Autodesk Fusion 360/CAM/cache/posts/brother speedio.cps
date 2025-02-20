/**
  Copyright (C) 2012-2021 by Autodesk, Inc.
  All rights reserved.

  Brother Speedio post processor configuration.

  $Revision: 43194 08c79bb5b30997ccb5fb33ab8e7c8c26981be334 $
  $Date: 2021-02-18 16:25:13 $
  
  FORKID {C09133CD-6F13-4DFC-9EB8-41260FBB5B08}
*/

description = "Brother Speedio";
vendor = "Brother";
vendorUrl = "http://www.brother.com";
legal = "Copyright (C) 2012-2021 by Autodesk, Inc.";
certificationLevel = 2;
minimumRevision = 45702;

longDescription = "Generic milling post for Brother Speedio S300X1, S500X1 and S700X1 machines.";

extension = "NC";
programNameIsInteger = false;
setCodePage("ascii");

capabilities = CAPABILITY_MILLING;
tolerance = spatial(0.002, MM);

minimumChordLength = spatial(0.25, MM);
minimumCircularRadius = spatial(0.01, MM);
maximumCircularRadius = spatial(1000, MM);
minimumCircularSweep = toRad(0.01);
maximumCircularSweep = toRad(180);
allowHelicalMoves = true;
allowedCircularPlanes = undefined; // allow any circular motion
highFeedrate = (unit == IN) ? 500 : 5000;

// user-defined properties
properties = {
  writeMachine: {
    title: "Write machine",
    description: "Output the machine settings in the header of the code.",
    group: 0,
    type: "boolean",
    value: true,
    scope: "post"
  },
  writeTools: {
    title: "Write tool list",
    description: "Output a tool list in the header of the code.",
    group: 0,
    type: "boolean",
    value: true,
    scope: "post"
  },
  preloadTool: {
    title: "Preload tool",
    description: "Preloads the next tool at a tool change (if any).",
    group: 1,
    type: "boolean",
    value: true,
    scope: "post"
  },
  showSequenceNumbers: {
    title: "Use sequence numbers",
    description: "Use sequence numbers for each block of outputted code.",
    group: 1,
    type: "boolean",
    value: true,
    scope: "post"
  },
  sequenceNumberStart: {
    title: "Start sequence number",
    description: "The number at which to start the sequence numbers.",
    group: 1,
    type: "integer",
    value: 10,
    scope: "post"
  },
  sequenceNumberIncrement: {
    title: "Sequence number increment",
    description: "The amount by which the sequence number is incremented by in each block.",
    group: 1,
    type: "integer",
    value: 5,
    scope: "post"
  },
  optionalStop: {
    title: "Optional stop",
    description: "Outputs optional stop code during when necessary in the code.",
    type: "boolean",
    value: true,
    scope: "post"
  },
  separateWordsWithSpace: {
    title: "Separate words with space",
    description: "Adds spaces between words if 'yes' is selected.",
    type: "boolean",
    value: true,
    scope: "post"
  },
  useRadius: {
    title: "Radius arcs",
    description: "If yes is selected, arcs are outputted using radius values rather than IJK.",
    type: "boolean",
    value: false,
    scope: "post"
  },
  useParametricFeed: {
    title: "Parametric feed",
    description: "Specifies the feed value that should be output using a Q value.",
    type: "boolean",
    value: false,
    scope: "post"
  },
  showNotes: {
    title: "Show notes",
    description: "Writes operation notes as comments in the outputted code.",
    type: "boolean",
    value: false,
    scope: "post"
  },
  useAAxis: {
    title: "Use A-axis",
    description: "Specifies whether to use the A axis.",
    type: "boolean",
    value: false,
    scope: "post"
  },
  useTrunnion: {
    title: "Use AC-trunnion",
    description: "Enables a trunnion table with an A and C-axis.",
    type: "boolean",
    value: false,
    scope: "post"
  },
  probingType: {
    title: "Probing type",
    description: "Specified what probing cycles are used on the machine.",
    type: "enum",
    values: [
      {title: "Renishaw", id: "Renishaw"},
      {title: "Blum", id: "Blum"}
    ],
    value: "Renishaw",
    scope: "post"
  },
  washdownCoolant: {
    title: "Washdown coolant",
    description: "Specifies whether washdown coolant should be used and where it is output.",
    type: "enum",
    values: [
      {title: "Off", id: "off"},
      {title: "Always on", id: "always"},
      {title: "End of operation", id: "operationEnd"},
      {title: "Program end", id: "programEnd"}
    ],
    value: "off",
    scope: "post"
  },
  usePitchForTapping: {
    title: "Use Pitch/TPI for tapping",
    description: "Specifies if high accuracy mode should be used.",
    type: "boolean",
    value: true,
    scope: "post"
  },
  doubleTapWithdrawSpeed: {
    title: "Double tap withdraw speed",
    description: "If enabled, a L value containing double the spindle speed (up to 6000) will be output in the G77 tapping cycle.",
    type: "boolean",
    value: false,
    scope: "post"
  },
  useSmoothing: {
    title: "Use high accuraccy mode",
    description: "Selects whether the feedrate, or pitch in MM or TPI for Inch is output for tapping cycles.",
    type: "boolean",
    value: false,
    scope: "post"
  },
  useInverseTime: {
    title: "Use inverse time feedrates",
    description: "'Yes' enables inverse time feedrates, 'No' outputs DPM feedrates.",
    type: "boolean",
    value: false,
    scope: "post"
  },
  safePositionMethod: {
    title: "Safe Retracts",
    description: "Select your desired retract option. 'Clearance Height' retracts to the operation clearance height.",
    type: "enum",
    values: [
      // {title:"G28", id: "G28"},
      {title: "G53", id: "G53"},
      {title: "Clearance Height", id: "clearanceHeight"}
    ],
    value: "G53",
    scope: "post"
  },
  singleResultsFile: {
    title: "Create single results file",
    description: "Set to false if you want to store the measurement results for each probe / inspection toolpath in a separate file",
    group: 0,
    type: "boolean",
    value: true,
    scope: "post"
  }
};

var singleLineCoolant = false; // specifies to output multiple coolant codes in one line rather than in separate lines
// samples:
// {id: COOLANT_THROUGH_TOOL, on: 88, off: 89}
// {id: COOLANT_THROUGH_TOOL, on: [8, 88], off: [9, 89]}
var coolants = [
  {id: COOLANT_FLOOD, on: 8},
  {id: COOLANT_MIST},
  {id: COOLANT_THROUGH_TOOL, on: 494, off: 495},
  {id: COOLANT_AIR},
  {id: COOLANT_AIR_THROUGH_TOOL},
  {id: COOLANT_SUCTION},
  {id: COOLANT_FLOOD_MIST},
  {id: COOLANT_FLOOD_THROUGH_TOOL, on: [8, 494], off: [9, 495]},
  {id: COOLANT_OFF, off: 9}
];
var washdownCoolant = {on: 400, off: 401};

var permittedCommentChars = " ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.,=_-";

var gFormat = createFormat({prefix:"G", width:2, zeropad:true, decimals:1});
var mFormat = createFormat({prefix:"M", width:2, zeropad:true, decimals:1});
var hFormat = createFormat({prefix:"H", width:2, zeropad:true, decimals:1});
var dFormat = createFormat({prefix:"D", width:2, zeropad:true, decimals:1});
var probeWCSFormat = createFormat({decimals:0, forceDecimal:true});

var xyzFormat = createFormat({decimals:(unit == MM ? 3 : 4), forceDecimal:false});
var rFormat = xyzFormat; // radius
var abcFormat = createFormat({decimals:3, forceDecimal:true, scale:DEG});
var feedFormat = createFormat({decimals:(unit == MM ? 0 : 1), forceDecimal:false});
var toolFormat = createFormat({width:2, zeropad:true, decimals:1});
var rpmFormat = createFormat({decimals:0});
var secFormat = createFormat({decimals:3, forceDecimal:true}); // seconds - range 0.001-99999.999
var taperFormat = createFormat({decimals:1, scale:DEG});

var xOutput = createVariable({prefix:"X"}, xyzFormat);
var yOutput = createVariable({prefix:"Y"}, xyzFormat);
var zOutput = createVariable({onchange: function() {retracted = false;}, prefix: "Z"}, xyzFormat);
var aOutput = createVariable({prefix:"A"}, abcFormat);
var bOutput = createVariable({prefix:"B"}, abcFormat);
var cOutput = createVariable({prefix:"C"}, abcFormat);
var feedOutput = createVariable({prefix:"F"}, feedFormat);
var cyclefeedOutput = createVariable({prefix:"F", force:true}, feedFormat);
var sOutput = createVariable({prefix:"S", force:true}, rpmFormat);
var dOutput = createVariable({}, dFormat);

// circular output
var iOutput = createReferenceVariable({prefix:"I"}, xyzFormat);
var jOutput = createReferenceVariable({prefix:"J"}, xyzFormat);
var kOutput = createReferenceVariable({prefix:"K"}, xyzFormat);

var gMotionModal = createModal({force:true}, gFormat); // modal group 1 // G0-G3, ...
var gPlaneModal = createModal({onchange:function () {gMotionModal.reset();}}, gFormat); // modal group 2 // G17-19
var gAbsIncModal = createModal({}, gFormat); // modal group 3 // G90-91
var gFeedModeModal = createModal({}, gFormat); // modal group 5 // G94-95
var gUnitModal = createModal({}, gFormat); // modal group 6 // G20-21
var gCycleModal = createModal({force:true}, gFormat); // modal group 9 // G81, ...
var gRetractModal = createModal({}, gFormat); // modal group 10 // G98-99
var gRotationModal = createModal({
  onchange: function () {
    if (probeVariables.probeAngleMethod == "G68") {
      probeVariables.outputRotationCodes = true;
    }
  }
}, gFormat); // modal group 16 // G68-G69

// fixed settings
var firstFeedParameter = 500;
var useMultiAxisFeatures = false;
var forceMultiAxisIndexing = false; // force multi-axis indexing for 3D programs
var cancelTiltFirst = true; // cancel G68.2 with G69 prior to G54-G59 WCS block
var useABCPrepositioning = false; // position ABC axes prior to G68.2 block

var WARNING_WORK_OFFSET = 0;

var allowIndexingWCSProbing = false; // specifies that probe WCS with tool orientation is supported
var probeVariables = {
  outputRotationCodes: false, // defines if it is required to output rotation codes
  probeAngleMethod: "OFF", // OFF, AXIS_ROT, G68, G54.4
  compensationXY: undefined
};

// collected state
var sequenceNumber;
var currentWorkOffset;
var optionalSection = false;
var forceSpindleSpeed = false;
var activeMovements; // do not use by default
var currentFeedId;
var retracted = false; // specifies that the tool has been retracted to the safe plane
probeMultipleFeatures = true;

/**
  Writes the specified block.
*/
function writeBlock() {
  var text = formatWords(arguments);
  if (!text) {
    return;
  }
  if (getProperty("showSequenceNumbers")) {
    if (optionalSection) {
      if (text) {
        writeWords("/", "N" + sequenceNumber, text);
      }
    } else {
      writeWords2("N" + sequenceNumber, arguments);
    }
    sequenceNumber += getProperty("sequenceNumberIncrement");
  } else {
    writeWords(arguments);
  }
}

/**
  Writes the specified optional block.
*/
function writeOptionalBlock() {
  if (getProperty("showSequenceNumbers")) {
    var words = formatWords(arguments);
    if (words) {
      writeWords("/", "N" + sequenceNumber, words);
      sequenceNumber += getProperty("sequenceNumberIncrement");
    }
  } else {
    writeWords("/", arguments);
  }
}

function formatComment(text) {
  return "(" + filterText(String(text).toUpperCase(), permittedCommentChars).replace(/[()]/g, "") + ")";
}

/**
  Output a comment.
*/
function writeComment(text) {
  writeln(formatComment(text));
}

function onOpen() {
  if (getProperty("useRadius")) {
    maximumCircularSweep = toRad(90); // avoid potential center calculation errors for CNC
  }
  gRotationModal.format(69); // Default to G69 Rotation Off

  if (getProperty("useTrunnion")) {
    var aAxis = createAxis({coordinate:0, table:true, axis:[1, 0, 0], range:[-30, 120], preference:1});
    var cAxis = createAxis({coordinate:2, table:true, axis:[0, 0, 1], cyclic:true});
    machineConfiguration = new MachineConfiguration(aAxis, cAxis);

    setMachineConfiguration(machineConfiguration);
    optimizeMachineAngles2(1); // TCP mode disabled
  } else if (getProperty("useAAxis")) { // note: setup your machine here
    var aAxis = createAxis({coordinate:0, table:true, axis:[1, 0, 0], range:[-360, 360], preference:1});
    machineConfiguration = new MachineConfiguration(aAxis);

    setMachineConfiguration(machineConfiguration);
    optimizeMachineAngles2(1); // TCP mode disabled
  }

  if (!machineConfiguration.isMachineCoordinate(0)) {
    aOutput.disable();
  }
  if (!machineConfiguration.isMachineCoordinate(1)) {
    bOutput.disable();
  }
  if (!machineConfiguration.isMachineCoordinate(2)) {
    cOutput.disable();
  }
  
  if (!getProperty("separateWordsWithSpace")) {
    setWordSeparator("");
  }

  sequenceNumber = getProperty("sequenceNumberStart");

  if (programName) {
    if (programComment) {
      writeComment(programName + " (" + filterText(String(programComment).toUpperCase(), permittedCommentChars) + ")");
    } else {
      writeComment(programName);
    }
  } else {
    error(localize("Program name has not been specified."));
    return;
  }

  // dump machine configuration
  var vendor = machineConfiguration.getVendor();
  var model = machineConfiguration.getModel();
  var description = machineConfiguration.getDescription();

  if (getProperty("writeMachine") && (vendor || model || description)) {
    writeComment(localize("Machine"));
    if (vendor) {
      writeComment("  " + localize("vendor") + ": " + vendor);
    }
    if (model) {
      writeComment("  " + localize("model") + ": " + model);
    }
    if (description) {
      writeComment("  " + localize("description") + ": "  + description);
    }
  }

  // dump tool information
  if (getProperty("writeTools")) {
    var zRanges = {};
    if (is3D()) {
      var numberOfSections = getNumberOfSections();
      for (var i = 0; i < numberOfSections; ++i) {
        var section = getSection(i);
        var zRange = section.getGlobalZRange();
        var tool = section.getTool();
        if (zRanges[tool.number]) {
          zRanges[tool.number].expandToRange(zRange);
        } else {
          zRanges[tool.number] = zRange;
        }
      }
    }

    var tools = getToolTable();
    if (tools.getNumberOfTools() > 0) {
      for (var i = 0; i < tools.getNumberOfTools(); ++i) {
        var tool = tools.getTool(i);
        var comment = "T" + toolFormat.format(tool.number) + " " +
          "D=" + xyzFormat.format(tool.diameter) + " " +
          localize("CR") + "=" + xyzFormat.format(tool.cornerRadius);
        if ((tool.taperAngle > 0) && (tool.taperAngle < Math.PI)) {
          comment += " " + localize("TAPER") + "=" + taperFormat.format(tool.taperAngle) + localize("deg");
        }
        if (zRanges[tool.number]) {
          comment += " - " + localize("ZMIN") + "=" + xyzFormat.format(zRanges[tool.number].getMinimum());
        }
        comment += " - " + getToolTypeName(tool.type);
        writeComment(comment);
      }
    }
  }
  
  if (false) {
    // check for duplicate tool number
    for (var i = 0; i < getNumberOfSections(); ++i) {
      var sectioni = getSection(i);
      var tooli = sectioni.getTool();
      for (var j = i + 1; j < getNumberOfSections(); ++j) {
        var sectionj = getSection(j);
        var toolj = sectionj.getTool();
        if (tooli.number == toolj.number) {
          if (xyzFormat.areDifferent(tooli.diameter, toolj.diameter) ||
              xyzFormat.areDifferent(tooli.cornerRadius, toolj.cornerRadius) ||
              abcFormat.areDifferent(tooli.taperAngle, toolj.taperAngle) ||
              (tooli.numberOfFlutes != toolj.numberOfFlutes)) {
            error(
              subst(
                localize("Using the same tool number for different cutter geometry for operation '%1' and '%2'."),
                sectioni.hasParameter("operation-comment") ? sectioni.getParameter("operation-comment") : ("#" + (i + 1)),
                sectionj.hasParameter("operation-comment") ? sectionj.getParameter("operation-comment") : ("#" + (j + 1))
              )
            );
            return;
          }
        }
      }
    }
  }

  if ((getNumberOfSections() > 0) && (getSection(0).workOffset == 0)) {
    for (var i = 0; i < getNumberOfSections(); ++i) {
      if (getSection(i).workOffset > 0) {
        error(localize("Using multiple work offsets is not possible if the initial work offset is 0."));
        return;
      }
    }
  }

  // absolute coordinates and feed per min
  writeBlock(gFormat.format(0), gAbsIncModal.format(90), gFormat.format(40), gFormat.format(80));
  writeBlock(gFeedModeModal.format(94), gFormat.format(49));

  writeComment("File output in " + (unit == 1 ? "MM" : "inches") + ". Please ensure the unit is set correctly on the control");
}

function onComment(message) {
  var comments = String(message).split(";");
  for (comment in comments) {
    writeComment(comments[comment]);
  }
}

/** Force output of X, Y, and Z. */
function forceXYZ() {
  xOutput.reset();
  yOutput.reset();
  zOutput.reset();
}

/** Force output of A, B, and C. */
function forceABC() {
  aOutput.reset();
  bOutput.reset();
  cOutput.reset();
}

function forceFeed() {
  currentFeedId = undefined;
  feedOutput.reset();
}

/** Force output of X, Y, Z, A, B, C, and F on next output. */
function forceAny() {
  forceXYZ();
  forceABC();
  forceFeed();
}

var currentSmoothing = false;

function setSmoothing(mode) {
  if (mode == currentSmoothing) {
    return false;
  }

  currentSmoothing = mode;

  if (!mode) { // disable high accuracy mode
    writeBlock(mFormat.format(269)); // reset G332 setting to machine default
  } else if (hasParameter("operation-strategy") && (getParameter("operation-strategy") == "drill")) {
    writeBlock(mFormat.format(269));
    currentSmoothing = false;
  } else if (hasParameter("operation:tolerance")) {
    var tolerance = Math.max(getParameter("operation:tolerance"), 0);
    if (tolerance > 0) {
      var stockToLeaveThreshold = toUnit(0.1, MM);
      var stockToLeave = 0;
      var verticalStockToLeave = 0;
      if (hasParameter("operation:stockToLeave")) {
        stockToLeave = xyzFormat.getResultingValue(getParameter("operation:stockToLeave"));
      }
      if (hasParameter("operation:verticalStockToLeave")) {
        verticalStockToLeave = xyzFormat.getResultingValue(getParameter("operation:verticalStockToLeave"));
      }

      var workMode;
      if ((stockToLeave > stockToLeaveThreshold) && (verticalStockToLeave > stockToLeaveThreshold)) {
        workMode = 265; // roughing
      } else {
        if ((stockToLeave > 0) || (verticalStockToLeave > 0)) {
          workMode = 260; // shape accuracy
        } else {
          workMode = 262; // shape & face accuracy
        }
      }
      writeBlock(mFormat.format(workMode)); // set tolerance mode
    } else {
      writeBlock(mFormat.format(265)); // high speed
    }
  } else {
    writeBlock(mFormat.format(265)); // high speed
  }
  return true;
}

function FeedContext(id, description, feed) {
  this.id = id;
  this.description = description;
  this.feed = feed;
}

function getFeed(f) {
  if (activeMovements) {
    var feedContext = activeMovements[movement];
    if (feedContext != undefined) {
      if (!feedFormat.areDifferent(feedContext.feed, f)) {
        if (feedContext.id == currentFeedId) {
          return ""; // nothing has changed
        }
        forceFeed();
        currentFeedId = feedContext.id;
        return "F#" + (firstFeedParameter + feedContext.id);
      }
    }
    currentFeedId = undefined; // force Q feed next time
  }
  return feedOutput.format(f); // use feed value
}

function initializeActiveFeeds() {
  activeMovements = new Array();
  var movements = currentSection.getMovements();
  
  var id = 0;
  var activeFeeds = new Array();
  if (hasParameter("operation:tool_feedCutting")) {
    if (movements & ((1 << MOVEMENT_CUTTING) | (1 << MOVEMENT_LINK_TRANSITION) | (1 << MOVEMENT_EXTENDED))) {
      var feedContext = new FeedContext(id, localize("Cutting"), getParameter("operation:tool_feedCutting"));
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_CUTTING] = feedContext;
      activeMovements[MOVEMENT_LINK_TRANSITION] = feedContext;
      activeMovements[MOVEMENT_EXTENDED] = feedContext;
    }
    ++id;
    if (movements & (1 << MOVEMENT_PREDRILL)) {
      feedContext = new FeedContext(id, localize("Predrilling"), getParameter("operation:tool_feedCutting"));
      activeMovements[MOVEMENT_PREDRILL] = feedContext;
      activeFeeds.push(feedContext);
    }
    ++id;
  }
  
  if (hasParameter("operation:finishFeedrate")) {
    if (movements & (1 << MOVEMENT_FINISH_CUTTING)) {
      var feedContext = new FeedContext(id, localize("Finish"), getParameter("operation:finishFeedrate"));
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_FINISH_CUTTING] = feedContext;
    }
    ++id;
  } else if (hasParameter("operation:tool_feedCutting")) {
    if (movements & (1 << MOVEMENT_FINISH_CUTTING)) {
      var feedContext = new FeedContext(id, localize("Finish"), getParameter("operation:tool_feedCutting"));
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_FINISH_CUTTING] = feedContext;
    }
    ++id;
  }
  
  if (hasParameter("operation:tool_feedEntry")) {
    if (movements & (1 << MOVEMENT_LEAD_IN)) {
      var feedContext = new FeedContext(id, localize("Entry"), getParameter("operation:tool_feedEntry"));
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_LEAD_IN] = feedContext;
    }
    ++id;
  }

  if (hasParameter("operation:tool_feedExit")) {
    if (movements & (1 << MOVEMENT_LEAD_OUT)) {
      var feedContext = new FeedContext(id, localize("Exit"), getParameter("operation:tool_feedExit"));
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_LEAD_OUT] = feedContext;
    }
    ++id;
  }

  if (hasParameter("operation:noEngagementFeedrate")) {
    if (movements & (1 << MOVEMENT_LINK_DIRECT)) {
      var feedContext = new FeedContext(id, localize("Direct"), getParameter("operation:noEngagementFeedrate"));
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_LINK_DIRECT] = feedContext;
    }
    ++id;
  } else if (hasParameter("operation:tool_feedCutting") &&
             hasParameter("operation:tool_feedEntry") &&
             hasParameter("operation:tool_feedExit")) {
    if (movements & (1 << MOVEMENT_LINK_DIRECT)) {
      var feedContext = new FeedContext(id, localize("Direct"), Math.max(getParameter("operation:tool_feedCutting"), getParameter("operation:tool_feedEntry"), getParameter("operation:tool_feedExit")));
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_LINK_DIRECT] = feedContext;
    }
    ++id;
  }
  
  /*
  if (hasParameter("operation:reducedFeedrate")) {
    if (movements & (1 << MOVEMENT_REDUCED)) {
      var feedContext = new FeedContext(id, localize("Reduced"), getParameter("operation:reducedFeedrate"));
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_REDUCED] = feedContext;
    }
    ++id;
  }
*/

  if (hasParameter("operation:tool_feedRamp")) {
    if (movements & ((1 << MOVEMENT_RAMP) | (1 << MOVEMENT_RAMP_HELIX) | (1 << MOVEMENT_RAMP_PROFILE) | (1 << MOVEMENT_RAMP_ZIG_ZAG))) {
      var feedContext = new FeedContext(id, localize("Ramping"), getParameter("operation:tool_feedRamp"));
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_RAMP] = feedContext;
      activeMovements[MOVEMENT_RAMP_HELIX] = feedContext;
      activeMovements[MOVEMENT_RAMP_PROFILE] = feedContext;
      activeMovements[MOVEMENT_RAMP_ZIG_ZAG] = feedContext;
    }
    ++id;
  }
  if (hasParameter("operation:tool_feedPlunge")) {
    if (movements & (1 << MOVEMENT_PLUNGE)) {
      var feedContext = new FeedContext(id, localize("Plunge"), getParameter("operation:tool_feedPlunge"));
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_PLUNGE] = feedContext;
    }
    ++id;
  }
  if (true) { // high feed
    if ((movements & (1 << MOVEMENT_HIGH_FEED)) || (highFeedMapping != HIGH_FEED_NO_MAPPING)) {
      var feed;
      if (hasParameter("operation:highFeedrateMode") && getParameter("operation:highFeedrateMode") != "disabled") {
        feed = getParameter("operation:highFeedrate");
      } else {
        feed = this.highFeedrate;
      }
      var feedContext = new FeedContext(id, localize("High Feed"), feed);
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_HIGH_FEED] = feedContext;
      activeMovements[MOVEMENT_RAPID] = feedContext;
    }
    ++id;
  }
  
  for (var i = 0; i < activeFeeds.length; ++i) {
    var feedContext = activeFeeds[i];
    writeBlock("#" + (firstFeedParameter + feedContext.id) + "=" + feedFormat.format(feedContext.feed), formatComment(feedContext.description));
  }
}

var currentWorkPlaneABC = undefined;

function forceWorkPlane() {
  currentWorkPlaneABC = undefined;
}

function cancelWorkPlane(force) {
  if (force) {
    gRotationModal.reset();
  }
  writeBlock(gRotationModal.format(69)); // cancel frame
  forceWorkPlane();
}

function setWorkPlane(abc) {
  if (!forceMultiAxisIndexing && is3D() && !machineConfiguration.isMultiAxisConfiguration()) {
    return; // ignore
  }

  if (!((currentWorkPlaneABC == undefined) ||
        abcFormat.areDifferent(abc.x, currentWorkPlaneABC.x) ||
        abcFormat.areDifferent(abc.y, currentWorkPlaneABC.y) ||
        abcFormat.areDifferent(abc.z, currentWorkPlaneABC.z))) {
    return; // no change
  }

  onCommand(COMMAND_UNLOCK_MULTI_AXIS);

  if (!retracted) {
    if (!getProperty("useAAxis") && !getProperty("useTrunnion")) {
      writeRetract(Z);
    }
  }

  if (useMultiAxisFeatures) {
    if (cancelTiltFirst) {
      cancelWorkPlane();
    }
    if (machineConfiguration.isMultiAxisConfiguration() && (useABCPrepositioning || abc.isZero())) {
      var angles = abc.isNonZero() ? getWorkPlaneMachineABC(currentSection.workPlane, false, false) : abc;
      gMotionModal.reset();
      writeBlock(
        gMotionModal.format(0),
        conditional(machineConfiguration.isMachineCoordinate(0), "A" + abcFormat.format(angles.x)),
        conditional(machineConfiguration.isMachineCoordinate(1), "B" + abcFormat.format(angles.y)),
        conditional(machineConfiguration.isMachineCoordinate(2), "C" + abcFormat.format(angles.z))
      );
    }
    if (abc.isNonZero()) {
      gRotationModal.reset();
      writeBlock(gRotationModal.format(68.2), "X" + xyzFormat.format(0), "Y" + xyzFormat.format(0), "Z" + xyzFormat.format(0), "I" + abcFormat.format(abc.x), "J" + abcFormat.format(abc.y), "K" + abcFormat.format(abc.z)); // set frame
      writeBlock(gFormat.format(53.1)); // turn machine
    } else {
      if (!cancelTiltFirst) {
        cancelWorkPlane();
      }
    }
  } else {
    var initialPosition = getFramePosition(currentSection.getInitialPosition());
    var _a = aOutput.format(abc.x);
    var _b = bOutput.format(abc.y);
    var _c = cOutput.format(abc.z);
    if (_a || _b || _c) {
      gMotionModal.reset();
      writeBlock(
        gMotionModal.format(0),
        conditional(machineConfiguration.isMachineCoordinate(0), _a),
        conditional(machineConfiguration.isMachineCoordinate(1), _b),
        conditional(machineConfiguration.isMachineCoordinate(2), _c),
        xOutput.format(initialPosition.x), yOutput.format(initialPosition.y)
      );
    }
  }
  
  onCommand(COMMAND_LOCK_MULTI_AXIS);

  currentWorkPlaneABC = abc;
}

var closestABC = false; // choose closest machine angles
var currentMachineABC;

function getWorkPlaneMachineABC(workPlane, _setWorkPlane, rotate) {
  var W = workPlane; // map to global frame

  var abc = machineConfiguration.getABC(W);
  if (closestABC) {
    if (currentMachineABC) {
      abc = machineConfiguration.remapToABC(abc, currentMachineABC);
    } else {
      abc = machineConfiguration.getPreferredABC(abc);
    }
  } else {
    abc = machineConfiguration.getPreferredABC(abc);
  }
  
  try {
    abc = machineConfiguration.remapABC(abc);
    if (_setWorkPlane) {
      currentMachineABC = abc;
    }
  } catch (e) {
    error(
      localize("Machine angles not supported") + ":"
      + conditional(machineConfiguration.isMachineCoordinate(0), " A" + abcFormat.format(abc.x))
      + conditional(machineConfiguration.isMachineCoordinate(1), " B" + abcFormat.format(abc.y))
      + conditional(machineConfiguration.isMachineCoordinate(2), " C" + abcFormat.format(abc.z))
    );
  }
  
  var direction = machineConfiguration.getDirection(abc);
  if (!isSameDirection(direction, W.forward)) {
    error(localize("Orientation not supported."));
  }
  
  if (!machineConfiguration.isABCSupported(abc)) {
    error(
      localize("Work plane is not supported") + ":"
      + conditional(machineConfiguration.isMachineCoordinate(0), " A" + abcFormat.format(abc.x))
      + conditional(machineConfiguration.isMachineCoordinate(1), " B" + abcFormat.format(abc.y))
      + conditional(machineConfiguration.isMachineCoordinate(2), " C" + abcFormat.format(abc.z))
    );
  }

  if (rotate) {
    var tcp = false;
    if (tcp) {
      setRotation(W); // TCP mode
    } else {
      var O = machineConfiguration.getOrientation(abc);
      var R = machineConfiguration.getRemainingOrientation(abc, W);
      setRotation(R);
    }
  }
  
  return abc;
}

function printProbeResults() {
  return ((currentSection.getParameter("printResults", 0) == 1) && (getProperty("probingType") == "Renishaw"));
}

var probeOutputWorkOffset = 1;

function onParameter(name, value) {
  if (name == "probe-output-work-offset") {
    probeOutputWorkOffset = (value > 0) ? value : 1;
  }
}

function onSection() {
  var forceToolAndRetract = optionalSection && !currentSection.isOptional();
  optionalSection = currentSection.isOptional();

  var insertToolCall = forceToolAndRetract || isFirstSection() ||
    currentSection.getForceToolChange && currentSection.getForceToolChange() ||
    (tool.number != getPreviousSection().getTool().number);
  
  retracted = false;
  var newWorkOffset = isFirstSection() ||
    (getPreviousSection().workOffset != currentSection.workOffset); // work offset changes
  var newWorkPlane = isFirstSection() ||
    !isSameDirection(getPreviousSection().getGlobalFinalToolAxis(), currentSection.getGlobalInitialToolAxis()) ||
    (currentSection.isOptimizedForMachine() && getPreviousSection().isOptimizedForMachine() &&
      Vector.diff(getPreviousSection().getFinalToolAxisABC(), currentSection.getInitialToolAxisABC()).length > 1e-4) ||
    (!machineConfiguration.isMultiAxisConfiguration() && currentSection.isMultiAxis()) ||
    (!getPreviousSection().isMultiAxis() && currentSection.isMultiAxis() ||
      getPreviousSection().isMultiAxis() && !currentSection.isMultiAxis()); // force newWorkPlane between indexing and simultaneous operations
  var forceSmoothing =  getProperty("useSmoothing") &&
    (hasParameter("operation-strategy") && (getParameter("operation-strategy") == "drill") ||
    !isFirstSection() && getPreviousSection().hasParameter("operation-strategy") && (getPreviousSection().getParameter("operation-strategy") == "drill")); // force smoothing in case !insertToolCall
  if (insertToolCall || newWorkOffset || newWorkPlane || forceSmoothing) {
    
    // stop spindle before retract during tool change
    if (insertToolCall && !isFirstSection()) {
      onCommand(COMMAND_STOP_SPINDLE);
      if (useMultiAxisFeatures) {
        writeRetract(Z);
        writeBlock(gFormat.format(49));
        cancelWorkPlane();
      }
    }
    
    if (!insertToolCall && (newWorkOffset || newWorkPlane)) {
      // retract to safe plane
      writeRetract(Z); // retract
      forceXYZ();
    }
    if ((insertToolCall && !isFirstSection()) || forceSmoothing) {
      // disableLengthCompensation(false);
      setSmoothing(false);
    }
  }

  writeln("");

  if (hasParameter("operation-comment")) {
    var comment = getParameter("operation-comment");
    if (comment) {
      writeComment(comment);
    }
  }
  
  if (getProperty("showNotes") && hasParameter("notes")) {
    var notes = getParameter("notes");
    if (notes) {
      var lines = String(notes).split("\n");
      var r1 = new RegExp("^[\\s]+", "g");
      var r2 = new RegExp("[\\s]+$", "g");
      for (line in lines) {
        var comment = lines[line].replace(r1, "").replace(r2, "");
        if (comment) {
          writeComment(comment);
        }
      }
    }
  }

  // wcs
  if (insertToolCall) { // force work offset when changing tool
    currentWorkOffset = undefined;
  }
  var workOffset = currentSection.workOffset;
  if (workOffset == 0) {
    warningOnce(localize("Work offset has not been specified. Using G54 as WCS."), WARNING_WORK_OFFSET);
    workOffset = 1;
  }
  if (workOffset != currentWorkOffset) {
    if (cancelTiltFirst) {
      cancelWorkPlane();
    }
    forceWorkPlane();
  }
  if (workOffset > 0) {
    if (workOffset > 6) {
      var p = workOffset - 6; // 1->...
      if (p > 300) {
        error(localize("Work offset out of range."));
        return;
      } else {
        if (workOffset != currentWorkOffset) {
          writeBlock(gFormat.format(54.1), "P" + p); // G54.1P
          currentWorkOffset = workOffset;
        }
      }
    } else {
      if (workOffset != currentWorkOffset) {
        writeBlock(gFormat.format(53 + workOffset)); // G54->G59
        currentWorkOffset = workOffset;
      }
    }
  }

  var scode = "";
  var abc = new Vector(0, 0, 0);
  var euler = new Vector(0, 0, 0);
  if (forceMultiAxisIndexing || !is3D() || machineConfiguration.isMultiAxisConfiguration()) { // use 5-axis indexing for multi-axis mode
    if (currentSection.isMultiAxis()) {
      abc = currentSection.getInitialToolAxisABC();
      forceWorkPlane();
      cancelTransformation();
    } else {
      abc = getWorkPlaneMachineABC(currentSection.workPlane, true, true);
      if (useMultiAxisFeatures) {
        euler = currentSection.workPlane.getEuler2(EULER_ZXZ_R);
        cancelTransformation();
      }
      // setWorkPlane will be called below
    }
  } else { // pure 3D
    var remaining = currentSection.workPlane;
    if (!isSameDirection(remaining.forward, new Vector(0, 0, 1))) {
      error(localize("Tool orientation is not supported."));
      return;
    }
    setRotation(remaining);
  }

  isSpeedDifferent = false;
  if (tool.type != TOOL_PROBE && (insertToolCall ||
    isFirstSection() ||
    (rpmFormat.areDifferent(spindleSpeed, getPreviousSection().getTool().spindleRPM)) ||
    (tool.clockwise != getPreviousSection().getTool().clockwise))) {
    isSpeedDifferent = true;
    if (spindleSpeed < 1) {
      error(localize("Spindle speed out of range."));
      return;
    }
    if (spindleSpeed > 99999) {
      warning(localize("Spindle speed exceeds maximum value."));
    }
  }

  var start = getFramePosition(currentSection.getInitialPosition());
  
  if (insertToolCall) {
    forceWorkPlane();
    
    setCoolant(COOLANT_OFF);

    if (!isFirstSection() && getProperty("optionalStop")) {
      onCommand(COMMAND_OPTIONAL_STOP);
    }

    if (tool.number > 99) {
      warning(localize("Tool number exceeds maximum value."));
    }
  
    writeBlock(gFormat.format(100),
      "T" + toolFormat.format(tool.number),
      conditional(!useMultiAxisFeatures, xOutput.format(start.x)),
      conditional(!useMultiAxisFeatures, yOutput.format(start.y)),
      gFormat.format(43),
      conditional(!useMultiAxisFeatures, zOutput.format(start.z)),
      (((getProperty("useAAxis") || getProperty("useTrunnion")) && abc) ? aOutput.format(abc.x) : undefined),
      ((getProperty("useTrunnion") && abc) ? cOutput.format(abc.z) : undefined),
      conditional(!useMultiAxisFeatures, hFormat.format(tool.lengthOffset)),
      conditional(tool.type != TOOL_PROBE, dFormat.format(tool.diameterOffset)),
      conditional(tool.type != TOOL_PROBE, sOutput.format(spindleSpeed)),
      conditional(tool.type != TOOL_PROBE, mFormat.format(tool.clockwise ? 3 : 4))
    );

    if (tool.comment) {
      writeComment(tool.comment);
    }
    var showToolZMin = false;
    if (showToolZMin) {
      if (is3D()) {
        var numberOfSections = getNumberOfSections();
        var zRange = currentSection.getGlobalZRange();
        var number = tool.number;
        for (var i = currentSection.getId() + 1; i < numberOfSections; ++i) {
          var section = getSection(i);
          if (section.getTool().number != number) {
            break;
          }
          zRange.expandToRange(section.getGlobalZRange());
        }
        writeComment(localize("ZMIN") + "=" + zRange.getMinimum());
      }
    }

    if (getProperty("preloadTool")) {
      var nextTool = getNextTool(tool.number);
      if (nextTool) {
        writeBlock("T" + toolFormat.format(nextTool.number));
      } else {
        // preload first tool
        var section = getSection(0);
        var firstToolNumber = section.getTool().number;
        if (tool.number != firstToolNumber) {
          writeBlock("T" + toolFormat.format(firstToolNumber));
        }
      }
    }
  } else if (tool.type != TOOL_PROBE && isSpeedDifferent) {
    writeBlock(sOutput.format(spindleSpeed));
  }

  onCommand(COMMAND_START_CHIP_TRANSPORT);
  if (forceMultiAxisIndexing || !is3D() || machineConfiguration.isMultiAxisConfiguration()) {
    // writeBlock(mFormat.format(xxx)); // shortest path traverse
  }

  if (!insertToolCall) {
    forceXYZ();
  }

  if (!currentSection.isMultiAxis() && (getProperty("useAAxis") || getProperty("useTrunnion"))) {
    if (!useMultiAxisFeatures) {
      setWorkPlane(abc);
    } else {
      setWorkPlane(euler);
    }
  }
  if (useMultiAxisFeatures) {
    forceAny();
    gMotionModal.reset();
    writeBlock(gMotionModal.format(0), xOutput.format(start.x), yOutput.format(start.y));
    writeBlock(gMotionModal.format(0), gFormat.format(43), zOutput.format(start.z), hFormat.format(tool.lengthOffset));
  }
  setProbeAngle(); // output probe angle rotations if required

  // set coolant after we have positioned at Z
  setCoolant(tool.coolant);
  // add dwell for through coolant if needed
  if (tool.coolant == COOLANT_THROUGH_TOOL || tool.coolant == COOLANT_AIR_THROUGH_TOOL || tool.coolant == COOLANT_FLOOD_THROUGH_TOOL) {
    if (isFirstSection()) {
      onDwell(1);
    } else {
      var lastCoolant = getPreviousSection().getTool().coolant;
      if (!(lastCoolant == COOLANT_THROUGH_TOOL || lastCoolant == COOLANT_AIR_THROUGH_TOOL || lastCoolant == COOLANT_FLOOD_THROUGH_TOOL)) {
        onDwell(1);
      }
    }
  }

  if (getProperty("useSmoothing")) {
    if (hasParameter("operation-strategy") && (getParameter("operation-strategy") != "drill")) {
      if (setSmoothing(true)) {
        // retracted = true; // force G43
      }
    } else {
      if (setSmoothing(false)) {
        // retracted = true; // force G43
      }
    }
  }

  forceAny();
  gMotionModal.reset();

  var initialPosition = getFramePosition(currentSection.getInitialPosition());
  if (!retracted && !insertToolCall) {
    if (getCurrentPosition().z < initialPosition.z) {
      writeBlock(gMotionModal.format(0), zOutput.format(initialPosition.z));
    }
  }

  if (tool.type != TOOL_PROBE && isFirstSection() && (getProperty("washdownCoolant") == "always")) {
    writeBlock(mFormat.format(washdownCoolant.on));
  }

  if (insertToolCall || retracted || (!isFirstSection() && getPreviousSection().isMultiAxis())) {
    var lengthOffset = tool.lengthOffset;
    if (lengthOffset > 99) {
      error(localize("Length offset out of range."));
      return;
    }

    writeBlock(gPlaneModal.format(17));
    
    if (!machineConfiguration.isHeadConfiguration()) {
      writeBlock(
        gAbsIncModal.format(90),
        gMotionModal.format(0), xOutput.format(initialPosition.x), yOutput.format(initialPosition.y)
      );
      writeBlock(gMotionModal.format(0), zOutput.format(initialPosition.z));
    } else {
      writeBlock(
        gAbsIncModal.format(90),
        gMotionModal.format(0),
        xOutput.format(initialPosition.x),
        yOutput.format(initialPosition.y),
        zOutput.format(initialPosition.z)
      );
    }

    gMotionModal.reset();
  } else {
    writeBlock(
      gAbsIncModal.format(90),
      gMotionModal.format(0),
      xOutput.format(initialPosition.x),
      yOutput.format(initialPosition.y)
    );
  }

  if (getProperty("useParametricFeed") &&
    hasParameter("operation-strategy") &&
    (getParameter("operation-strategy") != "drill") && // legacy
    !(currentSection.hasAnyCycle && currentSection.hasAnyCycle())) {
    if (!insertToolCall &&
      activeMovements &&
      (getCurrentSectionId() > 0) &&
      ((getPreviousSection().getPatternId() == currentSection.getPatternId()) && (currentSection.getPatternId() != 0))) {
      // use the current feeds
    } else {
      initializeActiveFeeds();
    }
  } else {
    activeMovements = undefined;
  }

  if (isProbeOperation()) {
    validate(probeVariables.probeAngleMethod != "G68", "You cannot probe while G68 Rotation is in effect.");
    validate(probeVariables.probeAngleMethod != "G54.4", "You cannot probe while workpiece setting error compensation G54.4 is enabled.");
    if (getProperty("probingType") == "Renishaw") {
      writeBlock(gFormat.format(65), "P" + 8832); // spin the probe on
      inspectionCreateResultsFileHeader();
    }
  }
}

function onDwell(seconds) {
  if (seconds > 99999.999) {
    warning(localize("Dwelling time is out of range."));
  }
  seconds = clamp(1, seconds, 99999999);
  writeBlock(gFeedModeModal.format(94), gFormat.format(4), "P" + secFormat.format(seconds));
}

function onSpindleSpeed(spindleSpeed) {
  writeBlock(sOutput.format(spindleSpeed));
}

function onCycle() {
  writeBlock(gPlaneModal.format(17));
}

function getCommonCycle(x, y, z, r) {
  forceXYZ(); // force xyz on first drill hole of any cycle
  return [xOutput.format(x), yOutput.format(y),
    zOutput.format(z),
    "R" + xyzFormat.format(r)];
}

/** Convert approach to sign. */
function approach(value) {
  validate((value == "positive") || (value == "negative"), "Invalid approach.");
  return (value == "positive") ? 1 : -1;
}

function setProbeAngleMethod() {
  probeVariables.probeAngleMethod = (machineConfiguration.getNumberOfAxes() < 5 || is3D()) ? (getProperty("useG54x4") ? "G54.4" : "G68") : "UNSUPPORTED";
  var axes = [machineConfiguration.getAxisU(), machineConfiguration.getAxisV(), machineConfiguration.getAxisW()];
  for (var i = 0; i < axes.length; ++i) {
    if (axes[i].isEnabled() && isSameDirection((axes[i].getAxis()).getAbsolute(), new Vector(0, 0, 1)) && axes[i].isTable()) {
      probeVariables.probeAngleMethod = "AXIS_ROT";
      break;
    }
  }
  probeVariables.outputRotationCodes = true;
}

/** Output rotation offset based on angular probing cycle. */
function setProbeAngle() {
  if (probeVariables.outputRotationCodes) {
    validate(probeOutputWorkOffset <= 6, "Angular Probing only supports work offsets 1-6.");
    if (probeVariables.probeAngleMethod == "G68" && (Vector.diff(currentSection.getGlobalInitialToolAxis(), new Vector(0, 0, 1)).length > 1e-4)) {
      error(localize("You cannot use multi axis toolpaths while G68 Rotation is in effect."));
    }
    var validateWorkOffset = false;
    switch (probeVariables.probeAngleMethod) {
    case "G54.4":
      var param = 26000 + (probeOutputWorkOffset * 10);
      writeBlock("#" + param + "=#135");
      writeBlock("#" + (param + 1) + "=#136");
      writeBlock("#" + (param + 5) + "=#144");
      writeBlock(gFormat.format(54.4), "P" + probeOutputWorkOffset);
      break;
    case "G68":
      gRotationModal.reset();
      gAbsIncModal.reset();
      var n = xyzFormat.format(0);
      writeBlock(
        gRotationModal.format(68), gAbsIncModal.format(90),
        probeVariables.compensationXY, "Z" + n, "I" + n, "J" + n, "K" + xyzFormat.format(1), "R[#144]"
      );
      validateWorkOffset = true;
      break;
    case "AXIS_ROT":
      var param = 5200 + probeOutputWorkOffset * 20 + 5;
      writeBlock("#" + param + " = " + "[#" + param + " + #144]");
      forceWorkPlane(); // force workplane to rotate ABC in order to apply rotation offsets
      currentWorkOffset = undefined; // force WCS output to make use of updated parameters
      validateWorkOffset = true;
      break;
    default:
      error(localize("Angular Probing is not supported for this machine configuration."));
      return;
    }
    if (validateWorkOffset) {
      for (var i = currentSection.getId(); i < getNumberOfSections(); ++i) {
        if (getSection(i).workOffset != currentSection.workOffset) {
          error(localize("WCS offset cannot change while using angle rotation compensation."));
          return;
        }
      }
    }
    probeVariables.outputRotationCodes = false;
  }
}

function protectedProbeMove(_cycle, x, y, z) {
  var _x = xOutput.format(x);
  var _y = yOutput.format(y);
  var _z = zOutput.format(z);
  var _code = getProperty("probingType") == "Renishaw" ? 8810 : 8703;
  if (_z && z >= getCurrentPosition().z) {
    writeBlock(gFormat.format(65), "P" + _code, _z, getFeed(cycle.feedrate)); // protected positioning move
  }
  if (_x || _y) {
    writeBlock(gFormat.format(65), "P" + _code, _x, _y, getFeed(highFeedrate)); // protected positioning move
  }
  if (_z && z < getCurrentPosition().z) {
    writeBlock(gFormat.format(65), "P" + _code, _z, getFeed(cycle.feedrate)); // protected positioning move
  }
}

function onCyclePoint(x, y, z) {
  if (cycleType == "inspect") {
    if (typeof inspectionCycleInspect == "function") {
      inspectionCycleInspect(cycle, x, y, z);
      return;
    } else {
      cycleNotSupported();
    }
  }
  if (!isSameDirection(getRotation().forward, new Vector(0, 0, 1))) {
    expandCyclePoint(x, y, z);
    return;
  }

  if (isProbeOperation()) {
    if (!useMultiAxisFeatures && !isSameDirection(currentSection.workPlane.forward, new Vector(0, 0, 1))) {
      if (!allowIndexingWCSProbing && currentSection.strategy == "probe") {
        error(localize("Updating WCS / work offset using probing is only supported by the CNC in the WCS frame."));
        return;
      }
    }
    if (printProbeResults()) {
      writeProbingToolpathInformation(z - cycle.depth + tool.diameter / 2);
      inspectionWriteCADTransform();
      inspectionWriteWorkplaneTransform();
      if (typeof inspectionWriteVariables == "function") {
        inspectionVariables.pointNumber += 1;
      }
    }
    protectedProbeMove(cycle, x, y, z);
  }

  if (isFirstCyclePoint() || isProbeOperation()) {
    if (!isProbeOperation()) {
      // return to initial Z which is clearance plane and set absolute mode
      repositionToCycleClearance(cycle, x, y, z);
    }

    var F = cycle.feedrate;
    var P = !cycle.dwell ? 0 : clamp(1, cycle.dwell, 99999999); // in seconds

    // tapping variables
    var tapUnit = unit;
    if (hasParameter("operation:tool_unit")) {
      if (getParameter("operation:tool_unit") == "inches") {
        tapUnit = IN;
      } else {
        tapUnit = MM;
      }
    }
    var threadPitch = tool.threadPitch;
    if (unit != tapUnit) {
      threadPitch /= (tapUnit == IN) ? 25.4 : (1.0 / 25.4);
    }

    var threadsPerInch = 1.0 / threadPitch;

    switch (cycleType) {
    case "drilling":
      writeBlock(
        gCycleModal.format(81),
        getCommonCycle(x, y, z, cycle.retract),
        cyclefeedOutput.format(F)
      );
      break;
    case "counter-boring":
      if (P > 0) {
        writeBlock(
          gCycleModal.format(82),
          getCommonCycle(x, y, z, cycle.retract),
          "P" + secFormat.format(P),
          cyclefeedOutput.format(F)
        );
      } else {
        writeBlock(
          gCycleModal.format(81),
          getCommonCycle(x, y, cycle.bottom, cycle.retract),
          cyclefeedOutput.format(F)
        );
      }
      break;
    case "chip-breaking":
      if ((cycle.accumulatedDepth < cycle.depth) || (P > 0)) {
        expandCyclePoint(x, y, z);
      } else {
        writeBlock(
          gCycleModal.format(73),
          getCommonCycle(x, y, cycle.bottom, cycle.retract),
          "Q" + xyzFormat.format(cycle.incrementalDepth),
          cyclefeedOutput.format(F)
        );
      }
      break;
    case "deep-drilling":
      if (P > 0) {
        expandCyclePoint(x, y, z);
      } else {
        writeBlock(
          gCycleModal.format(83),
          getCommonCycle(x, y, cycle.bottom, cycle.retract),
          "Q" + xyzFormat.format(cycle.incrementalDepth),
          // conditional(P > 0, "P" + secFormat.format(P)),
          cyclefeedOutput.format(F)
        );
      }
      break;
    case "tapping":
      if (!F) {
        F = tool.getTappingFeedrate();
      }
      if (getProperty("usePitchForTapping")) {
        writeBlock(
          gCycleModal.format((tool.type == TOOL_TAP_LEFT_HAND) ? 74 : 77),
          getCommonCycle(x, y, cycle.bottom, cycle.retract),
          conditional((P != 0), "P" + secFormat.format(P)),
          conditional((tapUnit == IN), "J" + xyzFormat.format(threadsPerInch)),
          conditional((tapUnit == MM), "I" + xyzFormat.format(threadPitch)),
          conditional(getProperty("doubleTapWithdrawSpeed"), "L" + (spindleSpeed * 2 > 6000 ? 6000 : spindleSpeed * 2))
        );
      } else {
        writeBlock(
          gCycleModal.format((tool.type == TOOL_TAP_LEFT_HAND) ? 74 : 77),
          getCommonCycle(x, y, cycle.bottom, cycle.retract),
          "P" + secFormat.format(P),
          cyclefeedOutput.format(F)
        );
      }
      break;
    case "left-tapping":
      if (!F) {
        F = tool.getTappingFeedrate();
      }
      if (getProperty("usePitchForTapping")) {
        writeBlock(
          gCycleModal.format(74),
          getCommonCycle(x, y, cycle.bottom, cycle.retract),
          conditional((P != 0), "P" + secFormat.format(P)),
          conditional((tapUnit == IN), "J" + xyzFormat.format(threadsPerInch)),
          conditional((tapUnit == MM), "I" + xyzFormat.format(threadPitch)),
          conditional(getProperty("doubleTapWithdrawSpeed"), "L" + (spindleSpeed * 2 > 6000 ? 6000 : spindleSpeed * 2))
        );
      } else {
        writeBlock(
          gCycleModal.format(74),
          getCommonCycle(x, y, z, cycle.retract),
          "P" + secFormat.format(P),
          cyclefeedOutput.format(F)
        );
      }
      break;
    case "right-tapping":
      if (!F) {
        F = tool.getTappingFeedrate();
      }
      if (getProperty("usePitchForTapping")) {
        writeBlock(
          gCycleModal.format(77),
          getCommonCycle(x, y, cycle.bottom, cycle.retract),
          conditional((P != 0), "P" + secFormat.format(P)),
          conditional((tapUnit == IN), "J" + xyzFormat.format(threadsPerInch)),
          conditional((tapUnit == MM), "I" + xyzFormat.format(threadPitch)),
          conditional(getProperty("doubleTapWithdrawSpeed"), "L" + (spindleSpeed * 2 > 6000 ? 6000 : spindleSpeed * 2))
        );
      } else {
        writeBlock(
          gCycleModal.format(77),
          getCommonCycle(x, y, z, cycle.retract),
          "P" + secFormat.format(P),
          cyclefeedOutput.format(F)
        );
      }
      break;
    case "tapping-with-chip-breaking":
    case "left-tapping-with-chip-breaking":
    case "right-tapping-with-chip-breaking":
      if (cycle.accumulatedDepth < cycle.depth) {
        error(localize("Accumulated pecking depth is not supported for tapping cycles with chip breaking."));
        return;
      } else {
        if (!F) {
          F = tool.getTappingFeedrate();
        }
        if (getProperty("usePitchForTapping")) {
          writeBlock(
            gCycleModal.format((tool.type == TOOL_TAP_LEFT_HAND) ? 74 : 77),
            getCommonCycle(x, y, cycle.bottom, cycle.retract),
            conditional((P != 0), "P" + secFormat.format(P)),
            "Q" + xyzFormat.format(cycle.incrementalDepth),
            conditional((tapUnit == IN), "J" + xyzFormat.format(threadsPerInch)),
            conditional((tapUnit == MM), "I" + xyzFormat.format(threadPitch)),
            conditional(getProperty("doubleTapWithdrawSpeed"), "L" + (spindleSpeed * 2 > 6000 ? 6000 : spindleSpeed * 2))
          );
        } else {
          writeBlock(
            gCycleModal.format((tool.type == TOOL_TAP_LEFT_HAND ? 74 : 77)),
            getCommonCycle(x, y, z, cycle.retract),
            "P" + secFormat.format(P),
            "Q" + xyzFormat.format(cycle.incrementalDepth),
            feedOutput.format(F)
          );
        }
      }
      break;
    case "fine-boring":
      writeBlock(
        gCycleModal.format(76),
        getCommonCycle(x, y, z, cycle.retract),
        "P" + secFormat.format(P), // not optional
        "Q" + xyzFormat.format(cycle.shift),
        feedOutput.format(F)
      );
      break;
    case "back-boring":
      var dx = (gPlaneModal.getCurrent() == 19) ? cycle.backBoreDistance : 0;
      var dy = (gPlaneModal.getCurrent() == 18) ? cycle.backBoreDistance : 0;
      var dz = (gPlaneModal.getCurrent() == 17) ? cycle.backBoreDistance : 0;
      writeBlock(
        gCycleModal.format(87),
        getCommonCycle(x, y, cycle.bottom - cycle.backBoreDistance, cycle.bottom),
        "Q" + xyzFormat.format(cycle.shift),
        "P" + secFormat.format(P), // not optional
        cyclefeedOutput.format(F)
      );
      break;
    case "reaming":
      if (P > 0) {
        writeBlock(
          gCycleModal.format(89),
          getCommonCycle(x, y, z, cycle.retract),
          "P" + secFormat.format(P),
          cyclefeedOutput.format(F)
        );
      } else {
        writeBlock(
          gCycleModal.format(85),
          getCommonCycle(x, y, z, cycle.retract),
          cyclefeedOutput.format(F)
        );
      }
      break;
    case "stop-boring":
      if (P > 0) {
        expandCyclePoint(x, y, z);
      } else {
        writeBlock(
          gCycleModal.format(86),
          getCommonCycle(x, y, z, cycle.retract),
          cyclefeedOutput.format(F)
        );
      }
      break;
    case "manual-boring":
      writeBlock(
        gCycleModal.format(88),
        getCommonCycle(x, y, z, cycle.retract),
        "P" + secFormat.format(P), // not optional
        cyclefeedOutput.format(F)
      );
      break;
    case "boring":
      if (P > 0) {
        writeBlock(
          gCycleModal.format(89),
          getCommonCycle(x, y, z, cycle.retract),
          "P" + secFormat.format(P), // not optional
          cyclefeedOutput.format(F)
        );
      } else {
        writeBlock(
          gCycleModal.format(85),
          getCommonCycle(x, y, z, cycle.retract),
          cyclefeedOutput.format(F)
        );
      }
      break;
    case "probing-x":
      protectedProbeMove(cycle, x, y, z - cycle.depth);
      writeBlock(
        gFormat.format(65), "P" + (getProperty("probingType") == "Renishaw" ? 8811 : 8700),
        "X" + xyzFormat.format(x + approach(cycle.approach1) * (cycle.probeClearance + tool.diameter / 2)),
        "Q" + xyzFormat.format(cycle.probeOvertravel),
        getProbingArguments(cycle, true)
      );
      break;
    case "probing-y":
      protectedProbeMove(cycle, x, y, z - cycle.depth);
      writeBlock(
        gFormat.format(65), "P" + (getProperty("probingType") == "Renishaw" ? 8811 : 8700),
        "Y" + xyzFormat.format(y + approach(cycle.approach1) * (cycle.probeClearance + tool.diameter / 2)),
        "Q" + xyzFormat.format(cycle.probeOvertravel),
        getProbingArguments(cycle, true)
      );
      break;
    case "probing-z":
      protectedProbeMove(cycle, x, y, Math.min(z - cycle.depth + cycle.probeClearance, cycle.retract));
      writeBlock(
        gFormat.format(65), "P" + (getProperty("probingType") == "Renishaw" ? 8811 : 8700),
        "Z" + xyzFormat.format(z - cycle.depth),
        "Q" + xyzFormat.format(cycle.probeOvertravel),
        getProbingArguments(cycle, true)
      );
      break;
    case "probing-x-wall":
      protectedProbeMove(cycle, x, y, z);
      if (getProperty("probingType") == "Renishaw") {
        writeBlock(
          gFormat.format(65), "P" + 8812,
          "X" + xyzFormat.format(cycle.width1),
          "Z" + xyzFormat.format(z - cycle.depth),
          "Q" + xyzFormat.format(cycle.probeOvertravel),
          "R" + xyzFormat.format(cycle.probeClearance),
          getProbingArguments(cycle, true)
        );
      } else {
        writeBlock(
          gFormat.format(65), "P" + 8700,
          "S" + xyzFormat.format(cycle.width1),
          "X1",
          "Z" + xyzFormat.format(-cycle.depth),
          "Q" + xyzFormat.format(cycle.probeOvertravel),
          "R" + xyzFormat.format(cycle.probeClearance),
          getProbingArguments(cycle, true)
        );
      }
      break;
    case "probing-y-wall":
      protectedProbeMove(cycle, x, y, z);
      if (getProperty("probingType") == "Renishaw") {
        writeBlock(
          gFormat.format(65), "P" + 8812,
          "Y" + xyzFormat.format(cycle.width1),
          "Z" + xyzFormat.format(z - cycle.depth),
          "Q" + xyzFormat.format(cycle.probeOvertravel),
          "R" + xyzFormat.format(cycle.probeClearance),
          getProbingArguments(cycle, true)
        );
      } else {
        writeBlock(
          gFormat.format(65), "P" + 8700,
          "S" + xyzFormat.format(cycle.width1),
          "Z" + xyzFormat.format(-cycle.depth),
          "Y1",
          "Q" + xyzFormat.format(cycle.probeOvertravel),
          "R" + xyzFormat.format(cycle.probeClearance),
          getProbingArguments(cycle, true)
        );
      }
      break;
    case "probing-x-channel":
      protectedProbeMove(cycle, x, y, z - cycle.depth);
      if (getProperty("probingType") == "Renishaw") {
        writeBlock(
          gFormat.format(65), "P" + 8812,
          "X" + xyzFormat.format(cycle.width1),
          "Q" + xyzFormat.format(cycle.probeOvertravel),
          // not required "R" + xyzFormat.format(cycle.probeClearance),
          getProbingArguments(cycle, true)
        );
      } else {
        writeBlock(
          gFormat.format(65), "P" + 8700,
          "S" + xyzFormat.format(cycle.width1),
          "X1",
          "Q" + xyzFormat.format(cycle.probeOvertravel),
          getProbingArguments(cycle, true)
        );
      }
      break;
    case "probing-x-channel-with-island":
      protectedProbeMove(cycle, x, y, z);
      if (getProperty("probingType") == "Renishaw") {
        writeBlock(
          gFormat.format(65), "P" + 8812,
          "X" + xyzFormat.format(cycle.width1),
          "Z" + xyzFormat.format(z - cycle.depth),
          "Q" + xyzFormat.format(cycle.probeOvertravel),
          "R" + xyzFormat.format(-cycle.probeClearance),
          getProbingArguments(cycle, true)
        );
      } else {
        writeBlock(
          gFormat.format(65), "P" + 8700,
          "R" + xyzFormat.format(-cycle.probeClearance),
          "S" + xyzFormat.format(cycle.width1),
          "Z" + xyzFormat.format(-cycle.depth),
          "X1",
          "Q" + xyzFormat.format(cycle.probeOvertravel),
          getProbingArguments(cycle, true)
        );
      }
      break;
    case "probing-y-channel":
      protectedProbeMove(cycle, x, y, z - cycle.depth);
      if (getProperty("probingType") == "Renishaw") {
        writeBlock(
          gFormat.format(65), "P" + 8812,
          "Y" + xyzFormat.format(cycle.width1),
          "Q" + xyzFormat.format(cycle.probeOvertravel),
          // not required "R" + xyzFormat.format(cycle.probeClearance),
          getProbingArguments(cycle, true)
        );
      } else {
        writeBlock(
          gFormat.format(65), "P" + 8700,
          "S" + xyzFormat.format(cycle.width1),
          "Y1",
          "Q" + xyzFormat.format(cycle.probeOvertravel),
          getProbingArguments(cycle, true)
        );
      }
      break;
    case "probing-y-channel-with-island":
      protectedProbeMove(cycle, x, y, z);
      if (getProperty("probingType") == "Renishaw") {
        writeBlock(
          gFormat.format(65), "P" + 8812,
          "Y" + xyzFormat.format(cycle.width1),
          "Z" + xyzFormat.format(z - cycle.depth),
          "Q" + xyzFormat.format(cycle.probeOvertravel),
          "R" + xyzFormat.format(-cycle.probeClearance),
          getProbingArguments(cycle, true)
        );
      } else {
        writeBlock(
          gFormat.format(65), "P" + 8700,
          "R" + xyzFormat.format(-cycle.probeClearance),
          "S" + xyzFormat.format(cycle.width1),
          "Z" + xyzFormat.format(-cycle.depth),
          "Y1",
          "Q" + xyzFormat.format(cycle.probeOvertravel),
          getProbingArguments(cycle, true)
        );
      }
      break;
    case "probing-xy-circular-boss":
      protectedProbeMove(cycle, x, y, z);
      if (getProperty("probingType") == "Renishaw") {
        writeBlock(
          gFormat.format(65), "P" + 8814,
          "D" + xyzFormat.format(cycle.width1),
          "Z" + xyzFormat.format(z - cycle.depth),
          "Q" + xyzFormat.format(cycle.probeOvertravel),
          "R" + xyzFormat.format(cycle.probeClearance),
          getProbingArguments(cycle, true)
        );
      } else {
        writeBlock(
          gFormat.format(65), "P" + 8700,
          "S" + xyzFormat.format(cycle.width1),
          "Z" + xyzFormat.format(-cycle.depth),
          "Q" + xyzFormat.format(cycle.probeOvertravel),
          "R" + xyzFormat.format(cycle.probeClearance),
          getProbingArguments(cycle, true)
        );
      }
      break;
    case "probing-xy-circular-partial-boss":
      protectedProbeMove(cycle, x, y, z);
      if (getProperty("probingType") == "Renishaw") {
        writeBlock(
          gFormat.format(65), "P" + 8823,
          "A" + xyzFormat.format(cycle.partialCircleAngleA),
          "B" + xyzFormat.format(cycle.partialCircleAngleB),
          "C" + xyzFormat.format(cycle.partialCircleAngleC),
          "D" + xyzFormat.format(cycle.width1),
          "Z" + xyzFormat.format(z - cycle.depth),
          "Q" + xyzFormat.format(cycle.probeOvertravel),
          "R" + xyzFormat.format(cycle.probeClearance),
          getProbingArguments(cycle, true)
        );
      } else {
        error(localize("XY circular partial boss probing is not supported."));
      }
      break;
    case "probing-xy-circular-hole":
      protectedProbeMove(cycle, x, y, z - cycle.depth);
      if (getProperty("probingType") == "Renishaw") {
        writeBlock(
          gFormat.format(65), "P" + 8814,
          "D" + xyzFormat.format(cycle.width1),
          "Q" + xyzFormat.format(cycle.probeOvertravel),
          // not required "R" + xyzFormat.format(cycle.probeClearance),
          getProbingArguments(cycle, true)
        );
      } else {
        writeBlock(
          gFormat.format(65), "P" + 8700,
          "S" + xyzFormat.format(cycle.width1),
          "Q" + xyzFormat.format(cycle.probeOvertravel),
          getProbingArguments(cycle, true)
        );
      }
      break;
    case "probing-xy-circular-partial-hole":
      protectedProbeMove(cycle, x, y, z - cycle.depth);
      if (getProperty("probingType") == "Renishaw") {
        writeBlock(
          gFormat.format(65), "P" + 8823,
          "A" + xyzFormat.format(cycle.partialCircleAngleA),
          "B" + xyzFormat.format(cycle.partialCircleAngleB),
          "C" + xyzFormat.format(cycle.partialCircleAngleC),
          "D" + xyzFormat.format(cycle.width1),
          "Q" + xyzFormat.format(cycle.probeOvertravel),
          getProbingArguments(cycle, true)
        );
      } else {
        error(localize("XY circular partial hole probing is not supported."));
      }
      break;
    case "probing-xy-circular-hole-with-island":
      protectedProbeMove(cycle, x, y, z);
      if (getProperty("probingType") == "Renishaw") {
        writeBlock(
          gFormat.format(65), "P" + 8814,
          "Z" + xyzFormat.format(z - cycle.depth),
          "D" + xyzFormat.format(cycle.width1),
          "Q" + xyzFormat.format(cycle.probeOvertravel),
          "R" + xyzFormat.format(-cycle.probeClearance),
          getProbingArguments(cycle, true)
        );
      } else {
        writeBlock(
          gFormat.format(65), "P" + 8700,
          "R" + xyzFormat.format(-cycle.probeClearance),
          "S" + xyzFormat.format(cycle.width1),
          "Q" + xyzFormat.format(cycle.probeOvertravel),
          "Z" + xyzFormat.format(-cycle.depth),
          getProbingArguments(cycle, true)
        );
      }
      break;
    case "probing-xy-circular-partial-hole-with-island":
      protectedProbeMove(cycle, x, y, z);
      if (getProperty("probingType") == "Renishaw") {
        writeBlock(
          gFormat.format(65), "P" + 8823,
          "Z" + xyzFormat.format(z - cycle.depth),
          "A" + xyzFormat.format(cycle.partialCircleAngleA),
          "B" + xyzFormat.format(cycle.partialCircleAngleB),
          "C" + xyzFormat.format(cycle.partialCircleAngleC),
          "D" + xyzFormat.format(cycle.width1),
          "Q" + xyzFormat.format(cycle.probeOvertravel),
          "R" + xyzFormat.format(-cycle.probeClearance),
          getProbingArguments(cycle, true)
        );
      } else {
        error(localize("XY circular partial hole with island probing is not supported."));
      }
      break;
    case "probing-xy-rectangular-hole":
      protectedProbeMove(cycle, x, y, z - cycle.depth);
      if (getProperty("probingType") == "Renishaw") {
        writeBlock(
          gFormat.format(65), "P" + 8812,
          "X" + xyzFormat.format(cycle.width1),
          "Q" + xyzFormat.format(cycle.probeOvertravel),
          // not required "R" + xyzFormat.format(-cycle.probeClearance),
          getProbingArguments(cycle, true)
        );
        writeBlock(
          gFormat.format(65), "P" + 8812,
          "Y" + xyzFormat.format(cycle.width2),
          "Q" + xyzFormat.format(cycle.probeOvertravel),
          // not required "R" + xyzFormat.format(-cycle.probeClearance),
          getProbingArguments(cycle, true)
        );
      } else {
        error(localize("XY rectangular hole probing is not supported."));
      }
      break;
    case "probing-xy-rectangular-boss":
      protectedProbeMove(cycle, x, y, z);
      if (getProperty("probingType") == "Renishaw") {
        writeBlock(
          gFormat.format(65), "P" + 8812,
          "Z" + xyzFormat.format(z - cycle.depth),
          "X" + xyzFormat.format(cycle.width1),
          "R" + xyzFormat.format(cycle.probeClearance),
          "Q" + xyzFormat.format(cycle.probeOvertravel),
          getProbingArguments(cycle, true)
        );
        writeBlock(
          gFormat.format(65), "P" + 8812,
          "Z" + xyzFormat.format(z - cycle.depth),
          "Y" + xyzFormat.format(cycle.width2),
          "R" + xyzFormat.format(cycle.probeClearance),
          "Q" + xyzFormat.format(cycle.probeOvertravel),
          getProbingArguments(cycle, true)
        );
      } else {
        zOutput.reset();
        writeBlock(
          gFormat.format(65), "P" + 8700,
          "S" + xyzFormat.format(cycle.width1),
          "X1",
          "Z" + xyzFormat.format(-cycle.depth),
          "Q" + xyzFormat.format(cycle.probeOvertravel),
          "R" + xyzFormat.format(cycle.probeClearance),
          getProbingArguments(cycle, true)
        );
        zOutput.reset();
        writeBlock(
          gFormat.format(65), "P" + 8700,
          "S" + xyzFormat.format(cycle.width2),
          "Y1",
          "Z" + xyzFormat.format(-cycle.depth),
          "Q" + xyzFormat.format(cycle.probeOvertravel),
          "R" + xyzFormat.format(cycle.probeClearance),
          getProbingArguments(cycle, true)
        );
      }
      break;
    case "probing-xy-rectangular-hole-with-island":
      protectedProbeMove(cycle, x, y, z);
      if (getProperty("probingType") == "Renishaw") {
        writeBlock(
          gFormat.format(65), "P" + 8812,
          "Z" + xyzFormat.format(z - cycle.depth),
          "X" + xyzFormat.format(cycle.width1),
          "Q" + xyzFormat.format(cycle.probeOvertravel),
          "R" + xyzFormat.format(-cycle.probeClearance),
          getProbingArguments(cycle, true)
        );
        writeBlock(
          gFormat.format(65), "P" + 8812,
          "Z" + xyzFormat.format(z - cycle.depth),
          "Y" + xyzFormat.format(cycle.width2),
          "Q" + xyzFormat.format(cycle.probeOvertravel),
          "R" + xyzFormat.format(-cycle.probeClearance),
          getProbingArguments(cycle, true)
        );
      } else {
        error(localize("XY rectangular hole with island probing is not supported."));
      }
      break;
    case "probing-xy-inner-corner":
      if (getProperty("probingType") == "Renishaw") {
        var cornerX = x + approach(cycle.approach1) * (cycle.probeClearance + tool.diameter / 2);
        var cornerY = y + approach(cycle.approach2) * (cycle.probeClearance + tool.diameter / 2);
        var cornerI = 0;
        var cornerJ = 0;
        if (cycle.probeSpacing !== undefined) {
          cornerI = cycle.probeSpacing;
          cornerJ = cycle.probeSpacing;
        }
        if ((cornerI != 0) && (cornerJ != 0)) {
          if (currentSection.strategy == "probe") {
            setProbeAngleMethod();
            probeVariables.compensationXY = "X[#135] Y[#136]";
          }
        }
        protectedProbeMove(cycle, x, y, z - cycle.depth);
        writeBlock(
          gFormat.format(65), "P" + 8815, xOutput.format(cornerX), yOutput.format(cornerY),
          conditional(cornerI != 0, "I" + xyzFormat.format(cornerI)),
          conditional(cornerJ != 0, "J" + xyzFormat.format(cornerJ)),
          "Q" + xyzFormat.format(cycle.probeOvertravel),
          getProbingArguments(cycle, true)
        );
      } else {
        error(localize("XY inner corner probing is not supported."));
      }
      break;
    case "probing-xy-outer-corner":
      var cornerX = x + approach(cycle.approach1) * (cycle.probeClearance + tool.diameter / 2);
      var cornerY = y + approach(cycle.approach2) * (cycle.probeClearance + tool.diameter / 2);
      var cornerI = 0;
      var cornerJ = 0;
      if (cycle.probeSpacing !== undefined) {
        cornerI = cycle.probeSpacing;
        cornerJ = cycle.probeSpacing;
      }
      if ((cornerI != 0) && (cornerJ != 0)) {
        if (currentSection.strategy == "probe") {
          setProbeAngleMethod();
          probeVariables.compensationXY = "X[#135] Y[#136]";
        }
      }
      protectedProbeMove(cycle, x, y, z - cycle.depth);
      if (getProperty("probingType") == "Renishaw") {
        writeBlock(
          gFormat.format(65), "P" + 8816, xOutput.format(cornerX), yOutput.format(cornerY),
          conditional(cornerI != 0, "I" + xyzFormat.format(cornerI)),
          conditional(cornerJ != 0, "J" + xyzFormat.format(cornerJ)),
          "Q" + xyzFormat.format(cycle.probeOvertravel),
          getProbingArguments(cycle, true)
        );
      } else {
        cornerX -= x;
        cornerY -= y;
        writeBlock(
          gFormat.format(65), "P" + 8700, xOutput.format(cornerX), yOutput.format(cornerY),
          "Q" + xyzFormat.format(cycle.probeOvertravel),
          getProbingArguments(cycle, true)
        );
      }
      break;
    case "probing-x-plane-angle":
      protectedProbeMove(cycle, x, y, z - cycle.depth);
      if (getProperty("probingType") == "Renishaw") {
        writeBlock(
          gFormat.format(65), "P" + 8843,
          "X" + xyzFormat.format(x + approach(cycle.approach1) * (cycle.probeClearance + tool.diameter / 2)),
          "D" + xyzFormat.format(cycle.probeSpacing),
          "Q" + xyzFormat.format(cycle.probeOvertravel),
          "A" + xyzFormat.format(cycle.nominalAngle != undefined ? cycle.nominalAngle : 90),
          getProbingArguments(cycle, false)
        );
        if (currentSection.strategy == "probe") {
          setProbeAngleMethod();
          probeVariables.compensationXY = "X" + xyzFormat.format(0) + " Y" + xyzFormat.format(0);
        }
      } else {
        error(localize("X angle probing is not supported."));
      }
      break;
    case "probing-y-plane-angle":
      protectedProbeMove(cycle, x, y, z - cycle.depth);
      if (getProperty("probingType") == "Renishaw") {
        writeBlock(
          gFormat.format(65), "P" + 8843,
          "Y" + xyzFormat.format(y + approach(cycle.approach1) * (cycle.probeClearance + tool.diameter / 2)),
          "D" + xyzFormat.format(cycle.probeSpacing),
          "Q" + xyzFormat.format(cycle.probeOvertravel),
          "A" + xyzFormat.format(cycle.nominalAngle != undefined ? cycle.nominalAngle : 0),
          getProbingArguments(cycle, false)
        );
        if (currentSection.strategy == "probe") {
          setProbeAngleMethod();
          probeVariables.compensationXY = "X" + xyzFormat.format(0) + " Y" + xyzFormat.format(0);
        }
      } else {
        error(localize("Y angle probing is not supported."));
      }
      break;
    case "probing-xy-pcd-hole":
      protectedProbeMove(cycle, x, y, z);
      if (getProperty("probingType") == "Renishaw") {
        writeBlock(
          gFormat.format(65), "P" + 8819,
          "A" + xyzFormat.format(cycle.pcdStartingAngle),
          "B" + xyzFormat.format(cycle.numberOfSubfeatures),
          "C" + xyzFormat.format(cycle.widthPCD),
          "D" + xyzFormat.format(cycle.widthFeature),
          "K" + xyzFormat.format(z - cycle.depth),
          "Q" + xyzFormat.format(cycle.probeOvertravel),
          getProbingArguments(cycle, false)
        );
        if (cycle.updateToolWear) {
          error(localize("Action -Update Tool Wear- is not supported with this cycle."));
          return;
        }
      } else {
        error(localize("XY PCD hole probing is not supported."));
      }
      break;
    case "probing-xy-pcd-boss":
      protectedProbeMove(cycle, x, y, z);
      if (getProperty("probingType") == "Renishaw") {
        writeBlock(
          gFormat.format(65), "P" + 8819,
          "A" + xyzFormat.format(cycle.pcdStartingAngle),
          "B" + xyzFormat.format(cycle.numberOfSubfeatures),
          "C" + xyzFormat.format(cycle.widthPCD),
          "D" + xyzFormat.format(cycle.widthFeature),
          "Z" + xyzFormat.format(z - cycle.depth),
          "Q" + xyzFormat.format(cycle.probeOvertravel),
          "R" + xyzFormat.format(cycle.probeClearance),
          getProbingArguments(cycle, false)
        );
        if (cycle.updateToolWear) {
          error(localize("Action -Update Tool Wear- is not supported with this cycle."));
          return;
        }
      } else {
        error(localize("XY PCD boss probing is not supported."));
      }
      break;
    default:
      expandCyclePoint(x, y, z);
    }
  } else {
    if (cycleExpanded) {
      expandCyclePoint(x, y, z);
    } else {
      writeBlock(xOutput.format(x), yOutput.format(y));
    }
  }
}

function getProbingArguments(cycle, updateWCS) {
  var outputWCSCode = updateWCS && currentSection.strategy == "probe";
  if (outputWCSCode) {
    validate(probeOutputWorkOffset <= 99, "Work offset is out of range.");
    var nextWorkOffset = hasNextSection() ? getNextSection().workOffset == 0 ? 1 : getNextSection().workOffset : -1;
    if (probeOutputWorkOffset == nextWorkOffset) {
      currentWorkOffset = undefined;
    }
  }
  if (getProperty("probingType") == "Renishaw") {
    return [
      (cycle.angleAskewAction == "stop-message" ? "B" + xyzFormat.format(cycle.toleranceAngle ? cycle.toleranceAngle : 0) : undefined),
      ((cycle.updateToolWear && cycle.toolWearErrorCorrection < 100) ? "F" + xyzFormat.format(cycle.toolWearErrorCorrection ? cycle.toolWearErrorCorrection / 100 : 100) : undefined),
      (cycle.wrongSizeAction == "stop-message" ? "H" + xyzFormat.format(cycle.toleranceSize ? cycle.toleranceSize : 0) : undefined),
      (cycle.outOfPositionAction == "stop-message" ? "M" + xyzFormat.format(cycle.tolerancePosition ? cycle.tolerancePosition : 0) : undefined),
      ((cycle.updateToolWear && cycleType == "probing-z") ? "T" + xyzFormat.format(cycle.toolLengthOffset) : undefined),
      ((cycle.updateToolWear && cycleType !== "probing-z") ? "T" + xyzFormat.format(cycle.toolDiameterOffset) : undefined),
      (cycle.updateToolWear ? "V" + xyzFormat.format(cycle.toolWearUpdateThreshold ? cycle.toolWearUpdateThreshold : 0) : undefined),
      (cycle.printResults ? "W" + xyzFormat.format(1 + cycle.incrementComponent) : undefined), // 1 for advance feature, 2 for reset feature count and advance component number. first reported result in a program should use W2.
      conditional(outputWCSCode, "S" + probeWCSFormat.format(probeOutputWorkOffset > 6 ? (probeOutputWorkOffset - 6 + 100) : probeOutputWorkOffset))
    ];
  } else {
    return [
      (cycle.wrongSizeAction == "stop-message" ? "T" + xyzFormat.format(cycle.toleranceSize ? cycle.toleranceSize : 0) : undefined),
      (cycle.outOfPositionAction == "stop-message" ? "T" + xyzFormat.format(cycle.tolerancePosition ? -1 * cycle.tolerancePosition : 0) : undefined),
      (cycle.updateToolWear ? "E" + xyzFormat.format(cycle.toolWearNumber) : undefined),
      conditional(outputWCSCode, "W" + probeWCSFormat.format(probeOutputWorkOffset > 6 ? -1 * (probeOutputWorkOffset - 6) : (probeOutputWorkOffset + 53)))
    ];
  }
}

function onCycleEnd() {
  if (isProbeOperation()) {
    zOutput.reset();
    gMotionModal.reset();
    if (getProperty("probingType") == "Renishaw") {
      writeBlock(gFormat.format(65), "P" + 8810, zOutput.format(cycle.retract)); // protected retract move
    } else {
      writeBlock(gFormat.format(65), "P" + 8703, zOutput.format(cycle.retract)); // protected retract move
    }
  } else if (!cycleExpanded) {
    writeBlock(gCycleModal.format(80));
    zOutput.reset();
  }
}

var pendingRadiusCompensation = -1;

function onRadiusCompensation() {
  pendingRadiusCompensation = radiusCompensation;
}

function onRapid(_x, _y, _z) {
  var x = xOutput.format(_x);
  var y = yOutput.format(_y);
  var z = zOutput.format(_z);
  if (x || y || z) {
    if (pendingRadiusCompensation >= 0) {
      error(localize("Radius compensation mode cannot be changed at rapid traversal."));
      return;
    }
    writeBlock(gMotionModal.format(0), x, y, z);
    forceFeed();
  }
}

function onLinear(_x, _y, _z, feed) {
  var x = xOutput.format(_x);
  var y = yOutput.format(_y);
  var z = zOutput.format(_z);
  var f = getFeed(feed);
  if (x || y || z) {
    if (pendingRadiusCompensation >= 0) {
      pendingRadiusCompensation = -1;
      var d = tool.diameterOffset;
      if (d > 99) {
        warning(localize("The diameter offset exceeds the maximum value."));
      }
      writeBlock(gPlaneModal.format(17));
      switch (radiusCompensation) {
      case RADIUS_COMPENSATION_LEFT:
        dOutput.reset();
        writeBlock(gMotionModal.format(1), gFormat.format(41), x, y, z, dOutput.format(d), f);
        break;
      case RADIUS_COMPENSATION_RIGHT:
        dOutput.reset();
        writeBlock(gMotionModal.format(1), gFormat.format(42), x, y, z, dOutput.format(d), f);
        break;
      default:
        writeBlock(gMotionModal.format(1), gFormat.format(40), x, y, z, f);
      }
    } else {
      writeBlock(gMotionModal.format(1), x, y, z, f);
    }
  } else if (f) {
    if (getNextRecord().isMotion()) { // try not to output feed without motion
      forceFeed(); // force feed on next line
    } else {
      writeBlock(gMotionModal.format(1), f);
    }
  }
}

function onRapid5D(_x, _y, _z, _a, _b, _c) {
  if (pendingRadiusCompensation >= 0) {
    error(localize("Radius compensation mode cannot be changed at rapid traversal."));
    return;
  }
  if (currentSection.isOptimizedForMachine()) {
    var x = xOutput.format(_x);
    var y = yOutput.format(_y);
    var z = zOutput.format(_z);
    var a = aOutput.format(_a);
    var b = bOutput.format(_b);
    var c = cOutput.format(_c);
    writeBlock(gMotionModal.format(0), x, y, z, a, b, c);
  } else {
    forceXYZ();
    var x = xOutput.format(_x);
    var y = yOutput.format(_y);
    var z = zOutput.format(_z);
    var i = ijkFormat.format(_a);
    var j = ijkFormat.format(_b);
    var k = ijkFormat.format(_c);
    writeBlock(gMotionModal.format(0), x, y, z, "I" + i, "J" + j, "K" + k);
  }
  forceFeed();
}

function onLinear5D(_x, _y, _z, _a, _b, _c, feed) {
  if (pendingRadiusCompensation >= 0) {
    error(localize("Radius compensation cannot be activated/deactivated for 5-axis move."));
    return;
  }

  if (currentSection.isOptimizedForMachine()) {
    var x = xOutput.format(_x);
    var y = yOutput.format(_y);
    var z = zOutput.format(_z);
    var a = aOutput.format(_a);
    var b = bOutput.format(_b);
    var c = cOutput.format(_c);

    // get feedrate number
    var f = {frn:0, fmode:0};
    if (a || b || c) {
      f = getMultiaxisFeed(_x, _y, _z, _a, _b, _c, feed);
      if (getProperty("useInverseTime")) {
        f.frn = inverseTimeOutput.format(f.frn);
      } else {
        f.frn = feedOutput.format(f.frn);
      }
    } else {
      f.frn = feedOutput.format(feed);
      f.fmode = 94;
    }

    if (x || y || z || a || b || c) {
      writeBlock(gFeedModeModal.format(f.fmode), gMotionModal.format(1), x, y, z, a, b, c, f.frn);
    } else if (f) {
      if (getNextRecord().isMotion()) { // try not to output feed without motion
        forceFeed(); // force feed on next line
      } else {
        writeBlock(gFeedModeModal.format(f.fmode), gMotionModal.format(1), f.frn);
      }
    }
  } else {
    forceXYZ();
    var x = xOutput.format(_x);
    var y = yOutput.format(_y);
    var z = zOutput.format(_z);
    var i = ijkFormat.format(_a);
    var j = ijkFormat.format(_b);
    var k = ijkFormat.format(_c);
    var f = getFeed(feed);
    if (x || y || z || i || j || k) {
      writeBlock(gFeedModeModal.format(94), gMotionModal.format(1), x, y, z, "I" + i, "J" + j, "K" + k, f);
    } else if (f) {
      if (getNextRecord().isMotion()) { // try not to output feed without motion
        forceFeed(); // force feed on next line
      } else {
        writeBlock(gFeedModeModal.format(94), gMotionModal.format(1), f);
      }
    }
  }
}

// Start of multi-axis feedrate logic
/***** You can add 'getProperty("useInverseTime'") if desired. *****/
/***** 'previousABC' can be added throughout to maintain previous rotary positions. Required for Mill/Turn machines. *****/
/***** 'headOffset' should be defined when a head rotary axis is defined. *****/
/***** The feedrate mode must be included in motion block output (linear, circular, etc.) for Inverse Time feedrate support. *****/
var dpmBPW = 0.1; // ratio of rotary accuracy to linear accuracy for DPM calculations
var inverseTimeUnits = 1.0; // 1.0 = minutes, 60.0 = seconds
var maxInverseTime = 9999.999; // maximum value to output for Inverse Time feeds
var maxDPM = 9999.99; // maximum value to output for DPM feeds
var useInverseTimeFeed = false; // use 1/T feeds
var inverseTimeFormat = createFormat({decimals:3, forceDecimal:true});
var inverseTimeOutput = createVariable({prefix:"F", force:true}, inverseTimeFormat);
var previousDPMFeed = 0; // previously output DPM feed
var dpmFeedToler = 0.5; // tolerance to determine when the DPM feed has changed
// var previousABC = new Vector(0, 0, 0); // previous ABC position if maintained in post, don't define if not used
var forceOptimized = undefined; // used to override optimized-for-angles points (XZC-mode)

/** Calculate the multi-axis feedrate number. */
function getMultiaxisFeed(_x, _y, _z, _a, _b, _c, feed) {
  var f = {frn:0, fmode:0};
  if (feed <= 0) {
    error(localize("Feedrate is less than or equal to 0."));
    return f;
  }
  
  var length = getMoveLength(_x, _y, _z, _a, _b, _c);
  
  if (getProperty("useInverseTime")) { // inverse time
    f.frn = getInverseTime(length.tool, feed);
    f.fmode = 93;
    feedOutput.reset();
  } else { // degrees per minute
    f.frn = getFeedDPM(length, feed);
    f.fmode = 94;
  }
  return f;
}

/** Returns point optimization mode. */
function getOptimizedMode() {
  if (forceOptimized != undefined) {
    return forceOptimized;
  }
  // return (currentSection.getOptimizedTCPMode() != 0); // TAG:doesn't return correct value
  return true; // always return false for non-TCP based heads
}
  
/** Calculate the DPM feedrate number. */
function getFeedDPM(_moveLength, _feed) {
  if ((_feed == 0) || (_moveLength.tool < 0.0001) || (toDeg(_moveLength.abcLength) < 0.0005)) {
    previousDPMFeed = 0;
    return _feed;
  }
  var moveTime = _moveLength.tool / _feed;
  if (moveTime == 0) {
    previousDPMFeed = 0;
    return _feed;
  }

  var dpmFeed;
  var tcp = false; // !getOptimizedMode() && (forceOptimized == undefined);   // set to false for rotary heads
  if (tcp) { // TCP mode is supported, output feed as FPM
    dpmFeed = _feed;
  } else if (false) { // standard DPM
    dpmFeed = Math.min(toDeg(_moveLength.abcLength) / moveTime, maxDPM);
    if (Math.abs(dpmFeed - previousDPMFeed) < dpmFeedToler) {
      dpmFeed = previousDPMFeed;
    }
  } else if (true) { // combination FPM/DPM
    var length = Math.sqrt(Math.pow(_moveLength.xyzLength, 2.0) + Math.pow((toDeg(_moveLength.abcLength) * dpmBPW), 2.0));
    dpmFeed = Math.min((length / moveTime), maxDPM);
    if (Math.abs(dpmFeed - previousDPMFeed) < dpmFeedToler) {
      dpmFeed = previousDPMFeed;
    }
  } else { // machine specific calculation
    dpmFeed = _feed;
  }
  previousDPMFeed = dpmFeed;
  return dpmFeed;
}

/** Calculate the Inverse time feedrate number. */
function getInverseTime(_length, _feed) {
  var inverseTime;
  if (_length < 1.e-6) { // tool doesn't move
    if (typeof maxInverseTime === "number") {
      inverseTime = maxInverseTime;
    } else {
      inverseTime = 999999;
    }
  } else {
    inverseTime = _feed / _length / inverseTimeUnits;
    if (typeof maxInverseTime === "number") {
      if (inverseTime > maxInverseTime) {
        inverseTime = maxInverseTime;
      }
    }
  }
  return inverseTime;
}

/** Calculate radius for each rotary axis. */
function getRotaryRadii(startTool, endTool, startABC, endABC) {
  var radii = new Vector(0, 0, 0);
  var startRadius;
  var endRadius;
  var axis = new Array(machineConfiguration.getAxisU(), machineConfiguration.getAxisV(), machineConfiguration.getAxisW());
  for (var i = 0; i < 3; ++i) {
    if (axis[i].isEnabled()) {
      var startRadius = getRotaryRadius(axis[i], startTool, startABC);
      var endRadius = getRotaryRadius(axis[i], endTool, endABC);
      radii.setCoordinate(axis[i].getCoordinate(), Math.max(startRadius, endRadius));
    }
  }
  return radii;
}

/** Calculate the distance of the tool position to the center of a rotary axis. */
function getRotaryRadius(axis, toolPosition, abc) {
  if (!axis.isEnabled()) {
    return 0;
  }

  var direction = axis.getEffectiveAxis();
  var normal = direction.getNormalized();
  // calculate the rotary center based on head/table
  var center;
  var radius;
  if (axis.isHead()) {
    var pivot;
    if (typeof headOffset === "number") {
      pivot = headOffset;
    } else {
      pivot = tool.getBodyLength();
    }
    if (axis.getCoordinate() == machineConfiguration.getAxisU().getCoordinate()) { // rider
      center = Vector.sum(toolPosition, Vector.product(machineConfiguration.getDirection(abc), pivot));
      center = Vector.sum(center, axis.getOffset());
      radius = Vector.diff(toolPosition, center).length;
    } else { // carrier
      var angle = abc.getCoordinate(machineConfiguration.getAxisU().getCoordinate());
      radius = Math.abs(pivot * Math.sin(angle));
      radius += axis.getOffset().length;
    }
  } else {
    center = axis.getOffset();
    var d1 = toolPosition.x - center.x;
    var d2 = toolPosition.y - center.y;
    var d3 = toolPosition.z - center.z;
    var radius = Math.sqrt(
      Math.pow((d1 * normal.y) - (d2 * normal.x), 2.0) +
      Math.pow((d2 * normal.z) - (d3 * normal.y), 2.0) +
      Math.pow((d3 * normal.x) - (d1 * normal.z), 2.0)
    );
  }
  return radius;
}
  
/** Calculate the linear distance based on the rotation of a rotary axis. */
function getRadialDistance(radius, startABC, endABC) {
  // calculate length of radial move
  var delta = Math.abs(endABC - startABC);
  if (delta > Math.PI) {
    delta = 2 * Math.PI - delta;
  }
  var radialLength = (2 * Math.PI * radius) * (delta / (2 * Math.PI));
  return radialLength;
}
  
/** Calculate tooltip, XYZ, and rotary move lengths. */
function getMoveLength(_x, _y, _z, _a, _b, _c) {
  // get starting and ending positions
  var moveLength = {};
  var startTool;
  var endTool;
  var startXYZ;
  var endXYZ;
  var startABC;
  if (typeof previousABC !== "undefined") {
    startABC = new Vector(previousABC.x, previousABC.y, previousABC.z);
  } else {
    startABC = getCurrentDirection();
  }
  var endABC = new Vector(_a, _b, _c);
    
  if (!getOptimizedMode()) { // calculate XYZ from tool tip
    startTool = getCurrentPosition();
    endTool = new Vector(_x, _y, _z);
    startXYZ = startTool;
    endXYZ = endTool;

    // adjust points for tables
    if (!machineConfiguration.getTableABC(startABC).isZero() || !machineConfiguration.getTableABC(endABC).isZero()) {
      startXYZ = machineConfiguration.getOrientation(machineConfiguration.getTableABC(startABC)).getTransposed().multiply(startXYZ);
      endXYZ = machineConfiguration.getOrientation(machineConfiguration.getTableABC(endABC)).getTransposed().multiply(endXYZ);
    }

    // adjust points for heads
    if (machineConfiguration.getAxisU().isEnabled() && machineConfiguration.getAxisU().isHead()) {
      if (typeof getOptimizedHeads === "function") { // use post processor function to adjust heads
        startXYZ = getOptimizedHeads(startXYZ.x, startXYZ.y, startXYZ.z, startABC.x, startABC.y, startABC.z);
        endXYZ = getOptimizedHeads(endXYZ.x, endXYZ.y, endXYZ.z, endABC.x, endABC.y, endABC.z);
      } else { // guess at head adjustments
        var startDisplacement = machineConfiguration.getDirection(startABC);
        startDisplacement.multiply(headOffset);
        var endDisplacement = machineConfiguration.getDirection(endABC);
        endDisplacement.multiply(headOffset);
        startXYZ = Vector.sum(startTool, startDisplacement);
        endXYZ = Vector.sum(endTool, endDisplacement);
      }
    }
  } else { // calculate tool tip from XYZ, heads are always programmed in TCP mode, so not handled here
    startXYZ = getCurrentPosition();
    endXYZ = new Vector(_x, _y, _z);
    startTool = machineConfiguration.getOrientation(machineConfiguration.getTableABC(startABC)).multiply(startXYZ);
    endTool = machineConfiguration.getOrientation(machineConfiguration.getTableABC(endABC)).multiply(endXYZ);
  }

  // calculate axes movements
  moveLength.xyz = Vector.diff(endXYZ, startXYZ).abs;
  moveLength.xyzLength = moveLength.xyz.length;
  moveLength.abc = Vector.diff(endABC, startABC).abs;
  for (var i = 0; i < 3; ++i) {
    if (moveLength.abc.getCoordinate(i) > Math.PI) {
      moveLength.abc.setCoordinate(i, 2 * Math.PI - moveLength.abc.getCoordinate(i));
    }
  }
  moveLength.abcLength = moveLength.abc.length;

  // calculate radii
  moveLength.radius = getRotaryRadii(startTool, endTool, startABC, endABC);
  
  // calculate the radial portion of the tool tip movement
  var radialLength = Math.sqrt(
    Math.pow(getRadialDistance(moveLength.radius.x, startABC.x, endABC.x), 2.0) +
    Math.pow(getRadialDistance(moveLength.radius.y, startABC.y, endABC.y), 2.0) +
    Math.pow(getRadialDistance(moveLength.radius.z, startABC.z, endABC.z), 2.0)
  );
  
  // calculate the tool tip move length
  // tool tip distance is the move distance based on a combination of linear and rotary axes movement
  moveLength.tool = moveLength.xyzLength + radialLength;

  // debug
  if (false) {
    writeComment("DEBUG - tool   = " + moveLength.tool);
    writeComment("DEBUG - xyz    = " + moveLength.xyz);
    var temp = Vector.product(moveLength.abc, 180 / Math.PI);
    writeComment("DEBUG - abc    = " + temp);
    writeComment("DEBUG - radius = " + moveLength.radius);
  }
  return moveLength;
}
// End of multi-axis feedrate logic

// Start of onRewindMachine logic
/***** Be sure to add 'safeRetractDistance' to post getProperty(" ")*****/
var performRewinds = false; // enables the onRewindMachine logic
var safeRetractFeed = (unit == IN) ? 20 : 500;
var safePlungeFeed = (unit == IN) ? 10 : 250;
var stockAllowance = new Vector(toPreciseUnit(0.1, IN), toPreciseUnit(0.1, IN), toPreciseUnit(0.1, IN));

/** Allow user to override the onRewind logic. */
function onRewindMachineEntry(_a, _b, _c) {
  return false;
}

/** Retract to safe position before indexing rotaries. */
function moveToSafeRetractPosition(isRetracted) {
  if (!isRetracted) {
    writeRetract(Z);
  }
  if (getProperty("forceHomeOnIndexing")) {
    writeRetract(X, Y);
  }
}

/** Return from safe position after indexing rotaries. */
function returnFromSafeRetractPosition(position) {
  forceXYZ();
  xOutput.reset();
  yOutput.reset();
  zOutput.disable();
  onExpandedRapid(position.x, position.y, position.z);
  zOutput.enable();
  onExpandedRapid(position.x, position.y, position.z);
}

/** Intersect the point-vector with the stock box. */
function intersectStock(point, direction) {
  var intersection = getWorkpiece().getRayIntersection(point, direction, stockAllowance);
  return intersection === null ? undefined : intersection.second;
}

/** Calculates the retract point using the stock box and safe retract distance. */
function getRetractPosition(currentPosition, currentDirection) {
  var retractPos = intersectStock(currentPosition, currentDirection);
  if (retractPos == undefined) {
    if (tool.getFluteLength() != 0) {
      retractPos = Vector.sum(currentPosition, Vector.product(currentDirection, tool.getFluteLength()));
    }
  }
  if ((retractPos != undefined) && getProperty("safeRetractDistance")) {
    retractPos = Vector.sum(retractPos, Vector.product(currentDirection, getProperty("safeRetractDistance")));
  }
  return retractPos;
}

/** Determines if the angle passed to onRewindMachine is a valid starting position. */
function isRewindAngleValid(_a, _b, _c) {
  // make sure the angles are different from the last output angles
  if (!abcFormat.areDifferent(getCurrentDirection().x, _a) &&
      !abcFormat.areDifferent(getCurrentDirection().y, _b) &&
      !abcFormat.areDifferent(getCurrentDirection().z, _c)) {
    error(
      localize("REWIND: Rewind angles are the same as the previous angles: ") +
      abcFormat.format(_a) + ", " + abcFormat.format(_b) + ", " + abcFormat.format(_c)
    );
    return false;
  }
  
  // make sure angles are within the limits of the machine
  var abc = new Array(_a, _b, _c);
  var ix = machineConfiguration.getAxisU().getCoordinate();
  var failed = false;
  if ((ix != -1) && !machineConfiguration.getAxisU().isSupported(abc[ix])) {
    failed = true;
  }
  ix = machineConfiguration.getAxisV().getCoordinate();
  if ((ix != -1) && !machineConfiguration.getAxisV().isSupported(abc[ix])) {
    failed = true;
  }
  ix = machineConfiguration.getAxisW().getCoordinate();
  if ((ix != -1) && !machineConfiguration.getAxisW().isSupported(abc[ix])) {
    failed = true;
  }
  if (failed) {
    error(
      localize("REWIND: Rewind angles are outside the limits of the machine: ") +
      abcFormat.format(_a) + ", " + abcFormat.format(_b) + ", " + abcFormat.format(_c)
    );
    return false;
  }
  
  return true;
}

function onRewindMachine(_a, _b, _c) {
  
  if (!performRewinds) {
    error(localize("REWIND: Rewind of machine is required for simultaneous multi-axis toolpath and has been disabled."));
    return;
  }
  
  // Allow user to override rewind logic
  if (onRewindMachineEntry(_a, _b, _c)) {
    return;
  }
  
  // Determine if input angles are valid or will cause a crash
  if (!isRewindAngleValid(_a, _b, _c)) {
    error(
      localize("REWIND: Rewind angles are invalid:") +
      abcFormat.format(_a) + ", " + abcFormat.format(_b) + ", " + abcFormat.format(_c)
    );
    return;
  }
  
  // Work with the tool end point
  if (currentSection.getOptimizedTCPMode() == 0) {
    currentTool = getCurrentPosition();
  } else {
    currentTool = machineConfiguration.getOrientation(getCurrentDirection()).multiply(getCurrentPosition());
  }
  var currentABC = getCurrentDirection();
  var currentDirection = machineConfiguration.getDirection(currentABC);
  
  // Calculate the retract position
  var retractPosition = getRetractPosition(currentTool, currentDirection);

  // Output warning that axes take longest route
  if (retractPosition == undefined) {
    error(localize("REWIND: Cannot calculate retract position."));
    return;
  } else {
    var text = localize("REWIND: Tool is retracting due to rotary axes limits.");
    warning(text);
    writeComment(text);
  }

  // Move to retract position
  var position;
  if (currentSection.getOptimizedTCPMode() == 0) {
    position = retractPosition;
  } else {
    position = machineConfiguration.getOrientation(getCurrentDirection()).getTransposed().multiply(retractPosition);
  }
  onExpandedLinear(position.x, position.y, position.z, safeRetractFeed);
  
  //Position to safe machine position for rewinding axes
  moveToSafeRetractPosition(false);

  // Rotate axes to new position above reentry position
  xOutput.disable();
  yOutput.disable();
  zOutput.disable();
  onRapid5D(position.x, position.y, position.z, _a, _b, _c);
  xOutput.enable();
  yOutput.enable();
  zOutput.enable();

  // Move back to position above part
  if (currentSection.getOptimizedTCPMode() != 0) {
    position = machineConfiguration.getOrientation(new Vector(_a, _b, _c)).getTransposed().multiply(retractPosition);
  }
  returnFromSafeRetractPosition(position);

  // Plunge tool back to original position
  if (currentSection.getOptimizedTCPMode() != 0) {
    currentTool = machineConfiguration.getOrientation(new Vector(_a, _b, _c)).getTransposed().multiply(currentTool);
  }
  onExpandedLinear(currentTool.x, currentTool.y, currentTool.z, safePlungeFeed);
}
// End of onRewindMachine logic

function onCircular(clockwise, cx, cy, cz, x, y, z, feed) {
  if (pendingRadiusCompensation >= 0) {
    error(localize("Radius compensation cannot be activated/deactivated for a circular move."));
    return;
  }

  var start = getCurrentPosition();

  if (isFullCircle()) {
    if (getProperty("useRadius") || isHelical()) { // radius mode does not support full arcs
      linearize(tolerance);
      return;
    }
    switch (getCircularPlane()) {
    case PLANE_XY:
      writeBlock(gFeedModeModal.format(94), gAbsIncModal.format(90), gPlaneModal.format(17), gMotionModal.format(clockwise ? 2 : 3), iOutput.format(cx - start.x, 0), jOutput.format(cy - start.y, 0), getFeed(feed));
      break;
    case PLANE_ZX:
      writeBlock(gFeedModeModal.format(94), gAbsIncModal.format(90), gPlaneModal.format(18), gMotionModal.format(clockwise ? 2 : 3), iOutput.format(cx - start.x, 0), kOutput.format(cz - start.z, 0), getFeed(feed));
      break;
    case PLANE_YZ:
      writeBlock(gFeedModeModal.format(94), gAbsIncModal.format(90), gPlaneModal.format(19), gMotionModal.format(clockwise ? 2 : 3), jOutput.format(cy - start.y, 0), kOutput.format(cz - start.z, 0), getFeed(feed));
      break;
    default:
      linearize(tolerance);
    }
  } else if (!getProperty("useRadius")) {
    switch (getCircularPlane()) {
    case PLANE_XY:
      writeBlock(gFeedModeModal.format(94), gAbsIncModal.format(90), gPlaneModal.format(17), gMotionModal.format(clockwise ? 2 : 3), xOutput.format(x), yOutput.format(y), zOutput.format(z), iOutput.format(cx - start.x, 0), jOutput.format(cy - start.y, 0), getFeed(feed));
      break;
    case PLANE_ZX:
      writeBlock(gFeedModeModal.format(94), gAbsIncModal.format(90), gPlaneModal.format(18), gMotionModal.format(clockwise ? 2 : 3), xOutput.format(x), yOutput.format(y), zOutput.format(z), iOutput.format(cx - start.x, 0), kOutput.format(cz - start.z, 0), getFeed(feed));
      break;
    case PLANE_YZ:
      writeBlock(gFeedModeModal.format(94), gAbsIncModal.format(90), gPlaneModal.format(19), gMotionModal.format(clockwise ? 2 : 3), xOutput.format(x), yOutput.format(y), zOutput.format(z), jOutput.format(cy - start.y, 0), kOutput.format(cz - start.z, 0), getFeed(feed));
      break;
    default:
      linearize(tolerance);
    }
  } else { // use radius mode
    var r = getCircularRadius();
    if (toDeg(getCircularSweep()) > 180) {
      r = -r; // allow up to <360 deg arcs
    }
    switch (getCircularPlane()) {
    case PLANE_XY:
      writeBlock(gFeedModeModal.format(94), gPlaneModal.format(17), gMotionModal.format(clockwise ? 2 : 3), xOutput.format(x), yOutput.format(y), zOutput.format(z), "R" + rFormat.format(r), getFeed(feed));
      break;
    case PLANE_ZX:
      writeBlock(gFeedModeModal.format(94), gPlaneModal.format(18), gMotionModal.format(clockwise ? 2 : 3), xOutput.format(x), yOutput.format(y), zOutput.format(z), "R" + rFormat.format(r), getFeed(feed));
      break;
    case PLANE_YZ:
      writeBlock(gFeedModeModal.format(94), gPlaneModal.format(19), gMotionModal.format(clockwise ? 2 : 3), xOutput.format(x), yOutput.format(y), zOutput.format(z), "R" + rFormat.format(r), getFeed(feed));
      break;
    default:
      linearize(tolerance);
    }
  }
}

var currentCoolantMode = COOLANT_OFF;
var coolantOff = undefined;
var firstThrough = true;
var addDwell = false;

function setCoolant(coolant) {
  var coolantCodes = getCoolantCodes(coolant);
  if (Array.isArray(coolantCodes)) {
    if (singleLineCoolant) {
      writeBlock(coolantCodes.join(getWordSeparator()));
    } else {
      for (var c in coolantCodes) {
        writeBlock(coolantCodes[c]);
      }
    }
    return undefined;
  }
  return coolantCodes;
}

function getCoolantCodes(coolant) {
  var multipleCoolantBlocks = new Array(); // create a formatted array to be passed into the outputted line
  if (!coolants) {
    error(localize("Coolants have not been defined."));
  }
  if (isProbeOperation()) { // avoid coolant output for probing
    coolant = COOLANT_OFF;
  }
  if (coolant == currentCoolantMode) {
    return undefined; // coolant is already active
  }
  if ((coolant != COOLANT_OFF) && (currentCoolantMode != COOLANT_OFF) && (coolantOff != undefined)) {
    if (Array.isArray(coolantOff)) {
      for (var i in coolantOff) {
        multipleCoolantBlocks.push(mFormat.format(coolantOff[i]));
      }
    } else {
      multipleCoolantBlocks.push(mFormat.format(coolantOff));
    }
  }

  var m;
  var coolantCodes = {};
  for (var c in coolants) { // find required coolant codes into the coolants array
    if (coolants[c].id == coolant) {
      coolantCodes.on = coolants[c].on;
      if (coolants[c].off != undefined) {
        coolantCodes.off = coolants[c].off;
        break;
      } else {
        for (var i in coolants) {
          if (coolants[i].id == COOLANT_OFF) {
            coolantCodes.off = coolants[i].off;
            break;
          }
        }
      }
    }
  }
  if (coolant == COOLANT_OFF) {
    m = !coolantOff ? coolantCodes.off : coolantOff; // use the default coolant off command when an 'off' value is not specified
  } else {
    coolantOff = coolantCodes.off;
    m = coolantCodes.on;
  }

  if (!m) {
    onUnsupportedCoolant(coolant);
    m = 9;
  } else {
    if (Array.isArray(m)) {
      for (var i in m) {
        multipleCoolantBlocks.push(mFormat.format(m[i]));
      }
    } else {
      multipleCoolantBlocks.push(mFormat.format(m));
    }
    currentCoolantMode = coolant;
    return multipleCoolantBlocks; // return the single formatted coolant value
  }
  return undefined;
}

var mapCommand = {
  COMMAND_STOP:0,
  COMMAND_OPTIONAL_STOP:1,
  COMMAND_END:2,
  COMMAND_SPINDLE_CLOCKWISE:3,
  COMMAND_SPINDLE_COUNTERCLOCKWISE:4,
  COMMAND_STOP_SPINDLE:5,
  COMMAND_ORIENTATE_SPINDLE:19
};

function onCommand(command) {
  switch (command) {
  case COMMAND_STOP:
    writeBlock(mFormat.format(0));
    forceSpindleSpeed = true;
    return;
  case COMMAND_START_SPINDLE:
    onCommand(tool.clockwise ? COMMAND_SPINDLE_CLOCKWISE : COMMAND_SPINDLE_COUNTERCLOCKWISE);
    return;
  case COMMAND_LOCK_MULTI_AXIS:
    return;
  case COMMAND_UNLOCK_MULTI_AXIS:
    return;
  case COMMAND_START_CHIP_TRANSPORT:
    return;
  case COMMAND_STOP_CHIP_TRANSPORT:
    return;
  case COMMAND_BREAK_CONTROL:
    return;
  case COMMAND_TOOL_MEASURE:
    return;
  }
  
  var stringId = getCommandStringId(command);
  var mcode = mapCommand[stringId];
  if (mcode != undefined) {
    writeBlock(mFormat.format(mcode));
  } else {
    onUnsupportedCommand(command);
  }
}

function onSectionEnd() {
  if (currentSection.isMultiAxis()) {
    writeBlock(gFeedModeModal.format(94)); // inverse time feed off
  }

  if (currentSection.isMultiAxis() && !currentSection.isOptimizedForMachine()) {
    writeBlock(gFormat.format(49));
  }
  setSmoothing(false);
  writeBlock(gPlaneModal.format(17));

  if (((getCurrentSectionId() + 1) >= getNumberOfSections()) ||
      (tool.number != getNextSection().getTool().number)) {
    onCommand(COMMAND_BREAK_CONTROL);
  }

  // the code below gets the machine angles from previous operation.  closestABC must also be set to true
  if (currentSection.isMultiAxis() && currentSection.isOptimizedForMachine()) {
    currentMachineABC = currentSection.getFinalToolAxisABC();
  }

  if (tool.type != TOOL_PROBE && getProperty("washdownCoolant") == "operationEnd") {
    writeBlock(mFormat.format(washdownCoolant.on));
    writeBlock(mFormat.format(washdownCoolant.off));
  }
  if (!isLastSection() && (getNextSection().getTool().coolant != tool.coolant)) {
    setCoolant(COOLANT_OFF);
  }
  if (isProbeOperation()) {
    if (getProperty("probingType") == "Renishaw") {
      writeBlock(gFormat.format(65), "P" + 8833); // spin the probe off
      if (probeVariables.probeAngleMethod != "G68") {
        setProbeAngle(); // output probe angle rotations if required
      }
    }
  }
  forceAny();
}

/** Output block to do safe retract and/or move to home position. */
function writeRetract() {
  var words = []; // store all retracted axes in an array
  var retractAxes = new Array(false, false, false);
  var method = getProperty("safePositionMethod");
  if (method == "clearanceHeight") {
    if (!is3D()) {
      error(localize("Retract option 'Clearance Height' is not supported for multi-axis machining."));
    }
    return;
  }
  validate(arguments.length != 0, "No axis specified for writeRetract().");

  for (i in arguments) {
    retractAxes[arguments[i]] = true;
  }
  if ((retractAxes[0] || retractAxes[1]) && !retracted) { // retract Z first before moving to X/Y home
    error(localize("Retracting in X/Y is not possible without being retracted in Z."));
    return;
  }
  // special conditions
  if (retractAxes[2]) { // Z doesn't use G53
    method = "G28";
  }
  if (gRotationModal.getCurrent() == 68) { // cancel G68 before retracting
    cancelWorkPlane(true);
  }
  // define home positions
  var _xHome;
  var _yHome;
  var _zHome;
  if (method == "G28") {
    _xHome = toPreciseUnit(0, MM);
    _yHome = toPreciseUnit(0, MM);
    _zHome = toPreciseUnit(0, MM);
  } else {
    _xHome = machineConfiguration.hasHomePositionX() ? machineConfiguration.getHomePositionX() : toPreciseUnit(0, MM);
    _yHome = machineConfiguration.hasHomePositionY() ? machineConfiguration.getHomePositionY() : toPreciseUnit(0, MM);
    _zHome = machineConfiguration.getRetractPlane() != 0 ? machineConfiguration.getRetractPlane() : toPreciseUnit(0, MM);
  }
  for (var i = 0; i < arguments.length; ++i) {
    switch (arguments[i]) {
    case X:
      words.push("X" + xyzFormat.format(_xHome));
      xOutput.reset();
      break;
    case Y:
      words.push("Y" + xyzFormat.format(_yHome));
      yOutput.reset();
      break;
    case Z:
      words.push("Z" + xyzFormat.format(_zHome));
      zOutput.reset();
      retracted = true;
      break;
    default:
      error(localize("Unsupported axis specified for writeRetract()."));
      return;
    }
  }
  if (words.length > 0) {
    switch (method) {
    case "G28":
      gMotionModal.reset();
      gAbsIncModal.reset();
      writeBlock(gFormat.format(28), gAbsIncModal.format(91), words);
      writeBlock(gAbsIncModal.format(90));
      break;
    case "G53":
      gMotionModal.reset();
      writeBlock(gAbsIncModal.format(90), gFormat.format(53), words);
      break;
    default:
      error(localize("Unsupported safe position method."));
      return;
    }
  }
}

var isDPRNTopen = false;
function inspectionCreateResultsFileHeader() {
  if (isDPRNTopen) {
    if (!getProperty("singleResultsFile")) {
      writeln("DPRNT[END]");
      writeBlock("PCLOS");
      isDPRNTopen = false;
    }
  }

  if (isProbeOperation() && !printProbeResults()) {
    return; // if print results is not desired by probe/ probeWCS
  }

  if (!isDPRNTopen) {
    writeBlock("PCLOS");
    writeBlock("POPEN");
    // check for existence of none alphanumeric characters but not spaces
    var resFile;
    if (getProperty("singleResultsFile")) {
      resFile = getParameter("job-description") + "-RESULTS";
    } else {
      resFile = getParameter("operation-comment") + "-RESULTS";
    }
    resFile = resFile.replace(/:/g, "-");
    resFile = resFile.replace(/[^a-zA-Z0-9 -]/g, "");
    resFile = resFile.replace(/\s/g, "-");
    writeln("DPRNT[START]");
    writeln("DPRNT[RESULTSFILE*" + resFile + "]");
    if (hasGlobalParameter("document-id")) {
      writeln("DPRNT[DOCUMENTID*" + getGlobalParameter("document-id") + "]");
    }
    if (hasGlobalParameter("model-version")) {
      writeln("DPRNT[MODELVERSION*" + getGlobalParameter("model-version") + "]");
    }
  }
  if (isProbeOperation() && printProbeResults()) {
    isDPRNTopen = true;
  }
}

function getPointNumber() {
  if (typeof inspectionWriteVariables == "function") {
    return (inspectionVariables.pointNumber);
  } else {
    return ("#122[60]");
  }
}

function inspectionWriteCADTransform() {
  var cadOrigin = currentSection.getModelOrigin();
  var cadWorkPlane = currentSection.getModelPlane().getTransposed();
  var cadEuler = cadWorkPlane.getEuler2(EULER_XYZ_S);
  writeln(
    "DPRNT[G331" +
    "*N" + getPointNumber() +
    "*A" + abcFormat.format(cadEuler.x) +
    "*B" + abcFormat.format(cadEuler.y) +
    "*C" + abcFormat.format(cadEuler.z) +
    "*X" + xyzFormat.format(-cadOrigin.x) +
    "*Y" + xyzFormat.format(-cadOrigin.y) +
    "*Z" + xyzFormat.format(-cadOrigin.z) +
    "]"
  );
}

function inspectionWriteWorkplaneTransform() {
  var orientation = (machineConfiguration.isMultiAxisConfiguration() && currentMachineABC != undefined) ? machineConfiguration.getOrientation(currentMachineABC) : currentSection.workPlane;
  var abc = orientation.getEuler2(EULER_XYZ_S);
  writeln("DPRNT[G330" +
    "*N" + getPointNumber() +
    "*A" + abcFormat.format(abc.x) +
    "*B" + abcFormat.format(abc.y) +
    "*C" + abcFormat.format(abc.z) +
    "*X0*Y0*Z0*I0*R0]"
  );
}

function writeProbingToolpathInformation(cycleDepth) {
  writeln("DPRNT[TOOLPATHID*" + getParameter("autodeskcam:operation-id") + "]");
  if (isInspectionOperation()) {
    writeln("DPRNT[TOOLPATH*" + getParameter("operation-comment") + "]");
  } else {
    writeln("DPRNT[CYCLEDEPTH*" + xyzFormat.format(cycleDepth) + "]");
  }
}

function onClose() {
  if (isDPRNTopen) {
    writeln("DPRNT[END]");
    writeBlock("PCLOS");
    isDPRNTopen = false;
    if (typeof inspectionProcessSectionEnd == "function") {
      inspectionProcessSectionEnd();
    }
  }

  if (probeVariables.probeAngleMethod == "G68") {
    cancelWorkPlane();
  }
  writeln("");
  optionalSection = false;

  setCoolant(COOLANT_OFF);
  if (tool.type != TOOL_PROBE && (getProperty("washdownCoolant") == "always" || getProperty("washdownCoolant") == "programEnd")) {
    if (getProperty("washdownCoolant") == "programEnd") {
      writeBlock(mFormat.format(washdownCoolant.on));
    }
    writeBlock(mFormat.format(washdownCoolant.off));
  }

  // reload first tool (handles retract)
  writeBlock(gFormat.format(100), "T" + toolFormat.format(getSection(0).getTool().number));
  if (useMultiAxisFeatures) {
    writeRetract(Z);
  } else {
    retracted = true; // tool call does a full retract along the z-axis
  }

  writeRetract(X, Y);
  if (useMultiAxisFeatures) {
    writeBlock(gFormat.format(49));
    forceWorkPlane();
  }
  setWorkPlane(new Vector(0, 0, 0)); // reset working plane

  if (useMultiAxisFeatures && (getProperty("useAAxis") || getProperty("useTrunnion"))) {
    writeBlock(
      gAbsIncModal.format(91), gFormat.format(28),
      conditional(machineConfiguration.isMachineCoordinate(0), "A" + abcFormat.format(0)),
      conditional(machineConfiguration.isMachineCoordinate(1), "B" + abcFormat.format(0)),
      conditional(machineConfiguration.isMachineCoordinate(2), "C" + abcFormat.format(0))
    );
  }
  onImpliedCommand(COMMAND_END);
  onImpliedCommand(COMMAND_STOP_SPINDLE);
  writeBlock(mFormat.format(30)); // stop program, spindle stop, coolant off
}

function setProperty(property, value) {
  properties[property].current = value;
}
