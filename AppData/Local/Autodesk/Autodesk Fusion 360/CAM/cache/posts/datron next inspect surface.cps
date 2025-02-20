/**
  Copyright (C) 2012-2020 by Autodesk, Inc.
  All rights reserved.

  DATRON post processor configuration.

  $Revision: 43308 933cfe0f559cb64042cbff14485e764f90947933 $
  $Date: 2021-05-07 05:50:05 $

  FORKID {21ADEFBF-939E-4D3F-A935-4E61F5958698}
*/

// >>>>> INCLUDED FROM ../../datron next.cps
description = "DATRON next";
vendor = "DATRON";
vendorUrl = "http://www.datron.com";
legal = "Copyright (C) 2012-2021 by Autodesk, Inc.";
certificationLevel = 2;
minimumRevision = 45702;

longDescription = "Post for Datron next control. This post is for use with the Datron neo CNC.";

extension = "simpl";
setCodePage("utf-8");

capabilities = CAPABILITY_MILLING;
tolerance = spatial(0.002, MM);

minimumChordLength = spatial(0.25, MM);
minimumCircularRadius = spatial(0.01, MM);
maximumCircularRadius = spatial(1000, MM);
minimumCircularSweep = toRad(0.01);
maximumCircularSweep = toRad(120);
allowHelicalMoves = true;
allowedCircularPlanes = (1 << PLANE_XY); // allow XY plane only
probeMultipleFeatures = true;

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
  writeDateAndTime: {
    title: "Write date and time",
    description: "Output date and time in the header of the code.",
    group: 0,
    type: "boolean",
    value: true,
    scope: "post"
  },
  showNotes: {
    title: "Show notes",
    description: "Writes operation notes as comments in the outputted code.",
    type: "boolean",
    value: false,
    scope: "post"
  },
  useSmoothing: {
    title: "Use smoothing",
    description: "Specifies that smoothing mode should be used.",
    type: "boolean",
    value: true,
    scope: "post"
  },
  useDynamic: {
    title: "Dynamic mode",
    description: "Specifies that dynamic mode should be used.",
    type: "boolean",
    value: true,
    scope: "post"
  },
  machineType: {
    title: "Machine type",
    description: "Specifies the DATRON machine type.",
    type: "enum",
    values: [
      {title: "NEO", id: "NEO"},
      {title: "MX Cube", id: "MX"},
      {title: "Cube", id: "Cube"}
    ],
    value: "NEO",
    scope: "post"
  },
  useParkPosition: {
    title: "Park at end of program",
    description: "Enable to use the park position at end of program.",
    type: "boolean",
    value: true,
    scope: "post"
  },
  writeToolTable: {
    title: "Write tool table",
    description: "Write a tool table containing geometric tool information.",
    group: 0,
    type: "boolean",
    value: true,
    scope: "post"
  },
  useSequences: {
    title: "Use sequences",
    description: "If enabled, sequences are used in the output format on large files.",
    type: "boolean",
    value: true,
    scope: "post"
  },
  useExternalSequencesFiles: {
    title: "Use external sequence files",
    description: "If enabled, an external sequence file is created for each operation.",
    type: "boolean",
    value: false,
    scope: "post"
  },
  writeCoolantCommands: {
    title: "Write coolant commands",
    description: "Enable/disable coolant code outputs for the entire program.",
    type: "boolean",
    value: true,
    scope: "post"
  },
  useParametricFeed: {
    title: "Parametric feed",
    description: "Specifies that parametric feedrates should be used.",
    type: "boolean",
    value: true,
    scope: "post"
  },
  waitAfterOperation: {
    title: "Wait after operation",
    description: "If enabled, an optional stop will get generated to pause after each operation.",
    type: "boolean",
    value: false,
    scope: "post"
  },
  rotaryAxisSetup: {
    title: "Rotary axis setup",
    description: "Specifies the rotary axis setup.",
    type: "enum",
    values: [
      {title: "No rotary axis", id: "NONE"},
      {title: "4th axis along X+", id: "4X"},
      {title: "DST (5 axis)", id: "DST"}
    ],
    value: "NONE",
    scope: "post"
  },
  useSuction: {
    title: "Use Suction",
    description: "Enable the suction for every operation.",
    type: "boolean",
    value: false,
    scope: "post"
  },
  createThreadChamfer: {
    title: "Create a Thread Chamfer",
    description: "Create a chamfer with the thread milling tool",
    type: "boolean",
    value: false,
    scope: "post"
  },
  preloadTool: {
    title: "Preload tool",
    description: "Preload the next Tool in the DATRON Tool assist.",
    type: "boolean",
    value: false,
    scope: "post"
  },
  useZAxisOffset: {
    title: "Output Z Offset command",
    description: "This creates a command to allow a manual Z offset for each operation.",
    type: "boolean",
    value: false,
    scope: "post"
  },
  useRtcp: {
    title: "Use RTCP",
    description: "Use the NEXT 5axis setup correction.",
    type: "boolean",
    value: false,
    scope: "post"
  }
};

var gFormat = createFormat({prefix:"G", width:2, zeropad:true, decimals:1});
var mFormat = createFormat({prefix:"M", width:2, zeropad:true, decimals:1});

var xyzFormat = createFormat({decimals:(unit == MM ? 5 : 5), forceDecimal:false});
var abcFormat = createFormat({decimals:5, scale:DEG});
var feedFormat = createFormat({decimals:(unit == MM ? 2 : 2)});
var toolFormat = createFormat({decimals:0});
var dimensionFormat = createFormat({decimals:(unit == MM ? 3 : 5), forceDecimal:false});
var rpmFormat = createFormat({decimals:0, scale:1});
var sleepFormat = createFormat({decimals:0, scale:1000}); // milliseconds
var workpieceFormat = createFormat({decimals:(unit == MM ? 3 : 4), forceSign:true, trim:false});

var toolOutput = createVariable({prefix:"Tool_", force:true}, toolFormat);
var feedOutput = createVariable({prefix:""}, feedFormat);

var xOutput = createVariable({prefix:" X="}, xyzFormat);
var yOutput = createVariable({prefix:" Y="}, xyzFormat);
var zOutput = createVariable({prefix:" Z="}, xyzFormat);
var aOutput = createVariable({prefix:" A="}, abcFormat);
var bOutput = createVariable({prefix:" B="}, abcFormat);
var cOutput = createVariable({prefix:" C="}, abcFormat);

var iOutput = createVariable({prefix:" dX=", force : true}, xyzFormat);
var jOutput = createVariable({prefix:" dY=", force : true}, xyzFormat);
var kOutput = createVariable({prefix:" dZ="}, xyzFormat);

// fixed settings
var useDatronFeedCommand = false; // unsupported for now, keep false
var spacingDepth = 0;
var spacingString = "  ";
var spacing = "##########################################################";
var currentWorkOffset;

// buffer for building up a program not serial created
var sequenceBuffer = new StringBuffer();

function NewOperation(operationCall) {
  this.operationCall = operationCall;
  this.operationProgram = new StringBuffer();
  this.operationProgram.append("");
}
var currentOperation;
function NewSimPLProgram() {
  this.moduleName = new StringBuffer();
  this.measuringSystem = "Metric";
  this.toolDescriptionList = new Array();
  this.workpieceGeometry = "";
  this.sequenceList = new Array();
  this.usingList = new Array();
  this.externalUsermodules = new Array();
  this.globalVariableList = new Array();
  this.mainProgram = new StringBuffer();
  this.operationList = new Array();
}

var SimPLProgram = new NewSimPLProgram();

// collected state
var currentFeedValue = -1;
var optionalSection = false;
var activeMovements; // do not use by default
var currentFeedId;

// format date + time
var timeFormat = createFormat({decimals:0, width:2, zeropad:true});
var now = new Date();
var nowDay = now.getDate();
var nowMonth = now.getMonth() + 1;
var nowHour = now.getHours();
var nowMin = now.getMinutes();
var nowSec = now.getSeconds();

function getSequenceName(section) {
  var sequenceName = "";
  if (getProperty("useExternalSequencesFiles")) {
    sequenceName += getProgramFilename();
  }
  sequenceName += "SEQUENCE_" + mapComment(getOperationDescription(section));
  return sequenceName;
}

function getProgramFilename() {
  var outputPath = getOutputPath();
  var programFilename = FileSystem.getFilename(outputPath.substr(0, outputPath.lastIndexOf("."))) + "_";
  return programFilename;
}

function getOperationName(section) {
  return "Operation_" + getOperationDescription(section);
}

function capitalizeFirstLetter(text) {
  return text.substring(0, 1).toUpperCase() + text.substring(1).toLowerCase();
}

function getSpacing() {
  var space = "";
  for (var i = 0; i < spacingDepth; i++) {
    space += spacingString;
  }
  return space;
}

/**
  Redirect the output to an infinite number of buffers
*/
var writeRedirectionStack = new Array();

function setWriteRedirection(redirectionBuffer) {
  writeRedirectionStack.push(redirectionBuffer);
}

function resetWriteRedirection() {
  writeRedirectionStack.pop();
}

/**
  Writes the specified block.
*/
function writeBlock() {
  var text = getSpacing() + formatWords(arguments);
  if (writeRedirectionStack.length == 0) {
    writeWords(text);
  } else {
    writeRedirectionStack[writeRedirectionStack.length - 1].append(text + EOL);
  }
}

/**
  Output a comment.
*/
function writeComment(text) {
  if (text) {
    text = getSpacing() + "# " + text;
    if (writeRedirectionStack.length == 0) {
      writeln(text);
    } else {
      writeRedirectionStack[writeRedirectionStack.length - 1].append(text + EOL);
    }
  }
}

var charMap = {
  "\u00c4" : "Ae",
  "\u00e4" : "ae",
  "\u00dc" : "Ue",
  "\u00fc" : "ue",
  "\u00d6" : "Oe",
  "\u00f6" : "oe",
  "\u00df" : "ss",
  "\u002d" : "_",
  "\u0020" : "_"
};

/** Map specific chars. */
function mapComment(text) {
  text = formatVariable(text);
  var result = "";
  for (var i = 0; i < text.length; ++i) {
    var ch = charMap[text[i]];
    result += ch ? ch : text[i];
  }
  return result;
}

function formatComment(text) {
  return mapComment(text);
}

function formatVariable(text) {
  return String(text).replace(/[^A-Za-z0-9\-_]/g, "");
}

function onOpen() {
  // note: setup your machine here
  if (getProperty("rotaryAxisSetup") == "4X") {
    var aAxis = createAxis({coordinate:0, table:true, axis:[1, 0, 0], range:[0, 360], cyclic:true, preference:0});
    machineConfiguration = new MachineConfiguration(aAxis);
    machineConfiguration.setVendor("DATRON");
    machineConfiguration.setModel("NEO with A Axis");
    machineConfiguration.setDescription("DATRON NEXT Control with additional A-Axis");
    setMachineConfiguration(machineConfiguration);
    optimizeMachineAngles2(getProperty("useRtcp") ? 0 : 1); // TCP mode 0:Full TCP 1: Map Tool Tip to Axis
  }

  if (getProperty("rotaryAxisSetup") == "DST") {
    var aAxis = createAxis({coordinate:0, table:true, axis:[1, 0, 0], range:[-10, 110], cyclic:false, preference:0});
    var cAxis = createAxis({coordinate:2, table:true, axis:[0, 0, 1], range:[-360, 360], cyclic:true, preference:0});
    machineConfiguration = new MachineConfiguration(aAxis, cAxis);
    machineConfiguration.setVendor("DATRON");
    machineConfiguration.setModel("NEXT with DST");
    machineConfiguration.setDescription("DATRON NEXT Control with additional DST");
    setMachineConfiguration(machineConfiguration);
    optimizeMachineAngles2(getProperty("useRtcp") ? 0 : 1); // TCP mode 0:Full TCP 1: Map Tool Tip to Axis
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

  // header
  writeProgramHeader();
  spacingDepth -= 1;
  resetWriteRedirection();

  // surface inspection
  if (typeof inspectionWriteVariables == "function") {
    inspectionWriteVariables();
  }
}

function getOperationDescription(section) {
  // creates the name of the operation
  var operationComment = "";
  if (section.hasParameter("operation-comment")) {
    operationComment = section.getParameter("operation-comment");
    operationComment = formatComment(operationComment);
  }

  var cycleTypeString = "";
  if (section.hasParameter("operation:cycleType")) {
    cycleTypeString = localize(section.getParameter("operation:cycleType")).toString();
    cycleTypeString = formatComment(cycleTypeString);
  }

  var sectionID = section.getId() + 1;
  var description = operationComment + "_" + cycleTypeString + "_" + sectionID;
  return description;
}

function createToolVariables() {
  var tools = getToolTable();
  var toolVariables = new Array();
  if (tools.getNumberOfTools() > 0 && !getProperty("writeToolTable")) {
    for (var i = 0; i < tools.getNumberOfTools(); ++i) {
      var tool = tools.getTool(i);
      toolVariables.push(toolOutput.format(tool.number) + ":number");
    }
  }
  return toolVariables;
}

function createToolDescriptionTable() {
  if (!getProperty("writeToolTable")) {
    return;
  }
  var toolDescriptionArray = new Array();
  var toolNameList = new Array();
  var numberOfSections = getNumberOfSections();
  for (var i = 0; i < numberOfSections; ++i) {
    var section = getSection(i);
    var tool = section.getTool();
    if (tool.type != TOOL_PROBE) {
      var toolName = createToolName(tool);
      var toolProgrammed = createToolDescription(tool);
      if (toolNameList.indexOf(toolName) == -1) {
        toolNameList.push(toolName);
        toolDescriptionArray.push(toolProgrammed);
      }
    }
  }

  SimPLProgram.toolDescriptionList = toolDescriptionArray;
}

function createToolDescription(tool) {
  var toolProgrammed = "@ ToolDescription : " +
      "\"" + "Name" + "\"" + ":" +  "\"" + createToolName(tool) + "\"" + ", " +
      "\"" + "Category" + "\"" + ":" +  "\"" + translateToolType(tool.type) + "\"" + ", " +
      "\"" + "ArticleNr" + "\"" + ":" +  "\"" + tool.productId + "\"" + ", " +
      "\"" + "ToolNumber" + "\"" + ":" + toolFormat.format(tool.number) + ", " +
      "\"" + "Vendor" + "\"" + ":" +  "\"" + tool.vendor + "\"" + ", " +
      "\"" + "Diameter" + "\"" + ":" + dimensionFormat.format(tool.diameter) + ", " +
      "\"" + "TipAngle" + "\"" + ":" + dimensionFormat.format(toDeg(tool.taperAngle)) + ", " +
      "\"" + "TipDiameter" + "\"" + ":" + dimensionFormat.format(tool.tipDiameter) + ", " +
      "\"" + "FluteLength" + "\"" + ":" + dimensionFormat.format(tool.fluteLength) + ", " +
      "\"" + "CornerRadius" + "\"" + ":" + dimensionFormat.format(tool.cornerRadius) + ", " +
      "\"" + "ShoulderLength" + "\"" + ":" + dimensionFormat.format(tool.shoulderLength) + ", " +
      "\"" + "ShoulderDiameter" + "\"" + ":" + dimensionFormat.format(tool.diameter) + ", " +
      "\"" + "BodyLength" + "\"" + ":" + dimensionFormat.format(tool.bodyLength) + ", " +
      "\"" + "NumberOfFlutes" + "\"" + ":" + toolFormat.format(tool.numberOfFlutes) + ", " +
      "\"" + "ThreadPitch" + "\"" + ":" + dimensionFormat.format(tool.threadPitch) + ", " +
      "\"" + "ShaftDiameter" + "\"" + ":" + dimensionFormat.format(tool.shaftDiameter) + ", " +
      "\"" + "OverallLength" + "\"" + ":" + dimensionFormat.format(tool.bodyLength + 2 * tool.shaftDiameter) +
      " @";
  return toolProgrammed;
}

/**
  Generate the logical tool name for the assignment table of used tools.
*/
function createToolName(tool) {
  var toolName = toolFormat.format(tool.number);
  toolName += "_" + translateToolType(tool.type);
  if (tool.comment) {
    toolName += "_" + tool.comment;
  }
  if (tool.diameter) {
    toolName += "_D" + dimensionFormat.format(tool.diameter);
  }
  var description = tool.getDescription();
  if (description) {
    toolName += "_" + description;
  }
  toolName = formatVariable(toolName);
  return toolName;
}

/**
  Translate HSM tools to Datron tool categories.
*/
function translateToolType(toolType) {

  var datronCategoryName = "";

  toolCategory = toolType;
  switch (toolType) {
  case TOOL_UNSPECIFIED:
    datronCategoryName = "Unspecified";
    break;
  case TOOL_DRILL:
    datronCategoryName = "Drill";
    break;
  case TOOL_DRILL_CENTER:
    datronCategoryName = "DrillCenter";
    break;
  case TOOL_DRILL_SPOT:
    datronCategoryName = "DrillSpot";
    break;
  case TOOL_DRILL_BLOCK:
    datronCategoryName = "DrillBlock";
    break;
  case TOOL_MILLING_END_FLAT:
    datronCategoryName = "MillingEndFlat";
    break;
  case TOOL_MILLING_END_BALL:
    datronCategoryName = "MillingEndBall";
    break;
  case TOOL_MILLING_END_BULLNOSE:
    datronCategoryName = "MillingEndBullnose";
    break;
  case TOOL_MILLING_CHAMFER:
    datronCategoryName = "Graver";
    break;
  case TOOL_MILLING_FACE:
    datronCategoryName = "MillingFace";
    break;
  case TOOL_MILLING_SLOT:
    datronCategoryName = "MillingSlot";
    break;
  case TOOL_MILLING_RADIUS:
    datronCategoryName = "MillingRadius";
    break;
  case TOOL_MILLING_DOVETAIL:
    datronCategoryName = "MillingDovetail";
    break;
  case TOOL_MILLING_TAPERED:
    datronCategoryName = "MillingTapered";
    break;
  case TOOL_MILLING_LOLLIPOP:
    datronCategoryName = "MillingLollipop";
    break;
  case TOOL_TAP_RIGHT_HAND:
    datronCategoryName = "TapRightHand";
    break;
  case TOOL_TAP_LEFT_HAND:
    datronCategoryName = "TapLeftHand";
    break;
  case TOOL_REAMER:
    datronCategoryName = "Reamer";
    break;
  case TOOL_BORING_BAR:
    datronCategoryName = "BoringBar";
    break;
  case TOOL_COUNTER_BORE:
    datronCategoryName = "CounterBore";
    break;
  case TOOL_COUNTER_SINK:
    datronCategoryName = "CounterSink";
    break;
  case TOOL_HOLDER_ONLY:
    datronCategoryName = "HolderOnly";
    break;
  case TOOL_PROBE:
    datronCategoryName = "XYZSensor";
    break;
  default:
    datronCategoryName = "Unspecified";
  }
  return datronCategoryName;
}

function writeProgramHeader() {
  // write creation Date
  setWriteRedirection(SimPLProgram.moduleName);
  if (getProperty("writeDateAndTime")) {
    var date = timeFormat.format(nowDay) + "." + timeFormat.format(nowMonth) + "." + now.getFullYear();
    var time = timeFormat.format(nowHour) + ":" + timeFormat.format(nowMin);
    writeComment("!File ; generated at " + date + " - " + time);
  } else {
    writeComment("!File ;");
  }

  if (programComment) {
    writeComment(formatComment(programComment));
  }

  writeBlock(" ");
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
      writeComment("  " + localize("description") + ": " + description);
    }
  }

  writeBlock("module " + "CamGeneratedModule");
  writeBlock(" ");

  writeBlock("@ MeasuringSystem = " + (unit == MM ? "\"" + "Metric" + "\"" + " @" : "\"" + "Imperial" + "\"" + " @"));
  resetWriteRedirection();

  // set the table of used tools in the header of the program
  createToolDescriptionTable();

  // set the workpiece information
  SimPLProgram.workpieceGeometry = writeWorkpiece();

  // set the sequence header in the program file
  if (getProperty("useSequences")) {
    var sequences = new Array();
    var numberOfSections = getNumberOfSections();
    for (var i = 0; i < numberOfSections; ++i) {
      var section = getSection(i);
      if (!isProbeOperation(section)) {
        sequences.push("sequence " + getSequenceName(section));
      }
    }
    if (getProperty("useExternalSequencesFiles")) {
      writeBlock("@ EmbeddedSequences = false @");
    }

    SimPLProgram.sequenceList = sequences;
  }

  // set usings
  SimPLProgram.usingList.push("using Base");
  if (getProperty("rotaryAxisSetup") != "NONE" && getProperty("useRtcp")) {
    SimPLProgram.usingList.push("using Rtcp");
  }
  if (getProperty("waitAfterOperation")) {
    SimPLProgram.usingList.push("import System");
  }

  if (typeof inspectionCycleInspect == "function") {
    addInspectionReferences();
  }
 
  // set paramtric feed variables
  for (var i = 0; i < getNumberOfSections(); ++i) {
    var section = getSection(i);
    if (getProperty("useParametricFeed") && (!useDatronFeedCommand)) {
      activeFeeds = initializeActiveFeeds(section);
      for (var j = 0; j < activeFeeds.length; ++j) {
        var feedContext = activeFeeds[j];
        var feedDescription = formatVariable(feedContext.description);
        if (SimPLProgram.globalVariableList.indexOf(feedDescription + ":number") == -1) {
          SimPLProgram.globalVariableList.push(feedDescription + ":number");
        }
      }
    }
  }

  setWriteRedirection(SimPLProgram.mainProgram);
  writeBlock("export program Main # " + (programName ? (SP + formatComment(programName)) : "") + ((unit == MM) ? " MM" : " INCH"));
  spacingDepth += 1;
  writeBlock("Absolute");

  // set the multiaxis mode
  if (getProperty("rotaryAxisSetup") != "NONE" && getProperty("useRtcp")) {
    writeBlock("MultiAxisMode On");
  }
  
  // set the parameter tool table
  SimPLProgram.globalVariableList.push(createToolVariables());

  // write the parameter tool table
  if (!getProperty("writeToolTable")) {
    var tools = getToolTable();
    writeComment("Number of tools in use" + ": " + tools.getNumberOfTools());
    if (tools.getNumberOfTools() > 0) {
      for (var i = 0; i < tools.getNumberOfTools(); ++i) {
        var tool = tools.getTool(i);
        var toolAsigment = toolOutput.format(tool.number) + " = " + (tool.number) + "# " +
          formatComment(getToolTypeName(tool.type)) + " " +
          "D:" + dimensionFormat.format(tool.diameter) + " " +
          "L2:" + dimensionFormat.format(tool.fluteLength) + " " +
          "L3:" + dimensionFormat.format(tool.shoulderLength) + " " +
          "ProductID:" + formatComment(tool.productId);
        writeBlock(toolAsigment);
      }
      writeBlock(" ");
    }
  }
  resetWriteRedirection();
}

function writeWorkpiece() {
  var workpieceString = new StringBuffer();
  setWriteRedirection(workpieceString);
  var workpiece = getWorkpiece();
  var delta = Vector.diff(workpiece.upper, workpiece.lower);

  writeBlock("# Workpiece dimensions");
  writeBlock(
    "# min:      X: " + workpieceFormat.format(workpiece.lower.x) + ";" +
    " Y: " + workpieceFormat.format(workpiece.lower.y) + ";" +
    " Z: " + workpieceFormat.format(workpiece.lower.z));
  writeBlock(
    "# max:      X: " + workpieceFormat.format(workpiece.upper.x) + ";" +
    " Y: " + workpieceFormat.format(workpiece.upper.y) + ";" +
    " Z: " + workpieceFormat.format(workpiece.upper.z));
  writeBlock(
    "# Part size X: " + workpieceFormat.format(delta.x) + ";" +
    " Y: " + workpieceFormat.format(delta.y) + ";" +
    " Z: " + workpieceFormat.format(delta.z));

  writeBlock("@ WorkpieceGeometry : " + "\"" + "MinEdge" + "\"" + ":{" + "\"" + "X" + "\"" + ":" + workpieceFormat.format(workpiece.lower.x) + "," +
    "\"" + "Y" + "\"" + ":" + workpieceFormat.format(workpiece.lower.y) + "," +
    "\"" + "Z" + "\"" + ":" +  workpieceFormat.format(workpiece.lower.z) + "}," +
    "\"" + "MaxEdge" + "\"" + ":{" + "\"" + "X" + "\"" + ":" + workpieceFormat.format(workpiece.upper.x) + "," +
    "\"" + "Y" + "\"" + ":" + workpieceFormat.format(workpiece.upper.y) + "," +
    "\"" + "Z" + "\"" + ":" + workpieceFormat.format(workpiece.upper.z) + "}" +
    " @");
  resetWriteRedirection();
  return workpieceString;
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
  currentFeedValue = -1;
}

/** Force output of X, Y, Z, A, B, C, and F on next output. */
function forceAny() {
  forceXYZ();
  forceABC();
  forceFeed();
}

function FeedContext(id, description, datronFeedName, feed) {
  this.id = id;
  this.description = description;
  this.datronFeedName = datronFeedName;
  if (revision < 41759) {
    this.feed = (unit == MM ? feed : toPreciseUnit(feed, MM)); // temporary solution
  } else {
    this.feed = feed;
  }
}

/** Maps the specified feed value to Q feed or formatted feed. */
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
        if (useDatronFeedCommand) {
          return ("Feed " + capitalizeFirstLetter(feedContext.datronFeedName));
        } else {
          return ("Feed=" + formatVariable(feedContext.description));
        }
      }
    }
    currentFeedId = undefined; // force Q feed next time
  }
  if (feedFormat.areDifferent(currentFeedValue, f)) {
    currentFeedValue = f;
    return "Feed=" + feedFormat.format(f);
  }
  return "";
}

function initializeActiveFeeds(section) {
  var activeFeeds = new Array();
  if (section.hasAnyCycle && section.hasAnyCycle()) {
    return activeFeeds;
  }
  activeMovements = new Array();
  var movements = section.getMovements();
  var id = 0;

  if (section.hasParameter("operation:tool_feedCutting")) {
    if (movements & ((1 << MOVEMENT_CUTTING) | (1 << MOVEMENT_LINK_TRANSITION) | (1 << MOVEMENT_EXTENDED))) {
      var feedContext = new FeedContext(id, localize("Cutting"), "roughing", section.getParameter("operation:tool_feedCutting"));
      addFeedContext(feedContext, activeFeeds);
      activeMovements[MOVEMENT_CUTTING] = feedContext;
      activeMovements[MOVEMENT_LINK_TRANSITION] = feedContext;
      activeMovements[MOVEMENT_EXTENDED] = feedContext;
    }
    ++id;
    if (movements & (1 << MOVEMENT_PREDRILL)) {
      feedContext = new FeedContext(id, localize("Predrilling"), "plunge", section.getParameter("operation:tool_feedCutting"));
      activeMovements[MOVEMENT_PREDRILL] = feedContext;
      addFeedContext(feedContext, activeFeeds);
    }
    ++id;
    if (section.hasParameter("operation-strategy") && (section.getParameter("operation-strategy") == "drill")) {
      var feedContext = new FeedContext(id, localize("Cutting"), "roughing", section.getParameter("operation:tool_feedCutting"));
      addFeedContext(feedContext, activeFeeds);
      activeMovements[MOVEMENT_CUTTING] = feedContext;
    }
    ++id;
  }
  if (section.hasParameter("operation:finishFeedrate")) {
    if (movements & (1 << MOVEMENT_FINISH_CUTTING)) {
      var feedContext = new FeedContext(id, localize("Finish"), "finishing", section.getParameter("operation:finishFeedrate"));
      addFeedContext(feedContext, activeFeeds);
      activeMovements[MOVEMENT_FINISH_CUTTING] = feedContext;
    }
    ++id;
  } else if (section.hasParameter("operation:tool_feedCutting")) {
    if (movements & (1 << MOVEMENT_FINISH_CUTTING)) {
      var feedContext = new FeedContext(id, localize("Finish"), "finishing", section.getParameter("operation:tool_feedCutting"));
      addFeedContext(feedContext, activeFeeds);
      activeMovements[MOVEMENT_FINISH_CUTTING] = feedContext;
    }
    ++id;
  }
  if (section.hasParameter("operation:tool_feedEntry")) {
    if (movements & (1 << MOVEMENT_LEAD_IN)) {
      var feedContext = new FeedContext(id, localize("Entry"), "approach", section.getParameter("operation:tool_feedEntry"));
      addFeedContext(feedContext, activeFeeds);
      activeMovements[MOVEMENT_LEAD_IN] = feedContext;
    }
    ++id;
  }
  if (section.hasParameter("operation:tool_feedExit")) {
    if (movements & (1 << MOVEMENT_LEAD_OUT)) {
      var feedContext = new FeedContext(id, localize("Exit"), "approach", section.getParameter("operation:tool_feedExit"));
      addFeedContext(feedContext, activeFeeds);
      activeMovements[MOVEMENT_LEAD_OUT] = feedContext;
    }
    ++id;
  }
  if (section.hasParameter("operation:noEngagementFeedrate")) {
    if (movements & (1 << MOVEMENT_LINK_DIRECT)) {
      var feedContext = new FeedContext(id, localize("Direct"), "approach", section.getParameter("operation:noEngagementFeedrate"));
      addFeedContext(feedContext, activeFeeds);
      activeMovements[MOVEMENT_LINK_DIRECT] = feedContext;
    }
    ++id;
  } else if (section.hasParameter("operation:tool_feedCutting") &&
    section.hasParameter("operation:tool_feedEntry") &&
    section.hasParameter("operation:tool_feedExit")) {
    if (movements & (1 << MOVEMENT_LINK_DIRECT)) {
      var feedContext = new FeedContext(id, localize("Direct"), "approach", Math.max(section.getParameter("operation:tool_feedCutting"), section.getParameter("operation:tool_feedEntry"), section.getParameter("operation:tool_feedExit")));
      addFeedContext(feedContext, activeFeeds);
      activeMovements[MOVEMENT_LINK_DIRECT] = feedContext;
    }
    ++id;
  }
  if (section.hasParameter("operation:reducedFeedrate")) {
    if (movements & (1 << MOVEMENT_REDUCED)) {
      var feedContext = new FeedContext(id, localize("Reduced"), "finishing", section.getParameter("operation:reducedFeedrate"));
      addFeedContext(feedContext, activeFeeds);
      activeMovements[MOVEMENT_REDUCED] = feedContext;
    }
    ++id;
  }
  if (section.hasParameter("operation:tool_feedRamp")) {
    if (movements & ((1 << MOVEMENT_RAMP) | (1 << MOVEMENT_RAMP_HELIX) | (1 << MOVEMENT_RAMP_PROFILE) | (1 << MOVEMENT_RAMP_ZIG_ZAG))) {
      var feedContext = new FeedContext(id, localize("Ramping"), "ramp", section.getParameter("operation:tool_feedRamp"));
      addFeedContext(feedContext, activeFeeds);
      activeMovements[MOVEMENT_RAMP] = feedContext;
      activeMovements[MOVEMENT_RAMP_HELIX] = feedContext;
      activeMovements[MOVEMENT_RAMP_PROFILE] = feedContext;
      activeMovements[MOVEMENT_RAMP_ZIG_ZAG] = feedContext;
    }
    ++id;
  }
  if (section.hasParameter("operation:tool_feedPlunge")) {
    if (movements & (1 << MOVEMENT_PLUNGE)) {
      var feedContext = new FeedContext(id, localize("Plunge"), "plunge", section.getParameter("operation:tool_feedPlunge"));
      addFeedContext(feedContext, activeFeeds);
      activeMovements[MOVEMENT_PLUNGE] = feedContext;
    }
    ++id;
  }

  // this part allows us to use feedContext also for the cycles
  if (hasParameter("operation:cycleType")) {
    var cycleType = getParameter("operation:cycleType");
    if (hasParameter("movement:plunge")) {
      var feedContext = new FeedContext(id, localize("Plunge"), "plunge", section.getParameter("movement:plunge"));
      addFeedContext(feedContext, activeFeeds);
      ++id;
    }

    switch (cycleType) {
    case "thread-milling":
      if (hasParameter("movement:plunge")) {
        var feedContext = new FeedContext(id, localize("Plunge"), "plunge", section.getParameter("movement:plunge"));
        addFeedContext(feedContext, activeFeeds);
        ++id;
      }
      if (hasParameter("movement:ramp")) {
        var feedContext = new FeedContext(id, localize("Ramping"), "ramp", section.getParameter("movement:ramp"));
        addFeedContext(feedContext, activeFeeds);
        ++id;
      }
      if (hasParameter("movement:finish_cutting")) {
        var feedContext = new FeedContext(id, localize("Finish"), "finishing", section.getParameter("movement:finish_cutting"));
        addFeedContext(feedContext, activeFeeds);
        ++id;
      }
      break;
    case "bore-milling":
      if (section.hasParameter("movement:plunge")) {
        var feedContext = new FeedContext(id, localize("Plunge"), "plunge", section.getParameter("movement:plunge"));
        addFeedContext(feedContext, activeFeeds);
        ++id;
      }
      if (section.hasParameter("movement:ramp")) {
        var feedContext = new FeedContext(id, localize("Ramping"), "ramp", section.getParameter("movement:ramp"));
        addFeedContext(feedContext, activeFeeds);
        ++id;
      }
      if (hasParameter("movement:finish_cutting")) {
        var feedContext = new FeedContext(id, localize("Finish"), "finishing", section.getParameter("movement:finish_cutting"));
        addFeedContext(feedContext, activeFeeds);
        ++id;
      }
      break;
    }
  }

  if (true) { // high feed
    if (movements & (1 << MOVEMENT_HIGH_FEED)) {
      var feedContext = new FeedContext(id, localize("High Feed"), "roughing", this.highFeedrate);
      addFeedContext(feedContext, activeFeeds);
      activeMovements[MOVEMENT_HIGH_FEED] = feedContext;
    }
    ++id;
  }
  return activeFeeds;
}

/** Check that all elements are only one time in the result list. */
function addFeedContext(feedContext, activeFeeds) {
  if (activeFeeds.indexOf(feedContext) == -1) {
    activeFeeds.push(feedContext);
  }
}

var currentWorkPlaneABC = undefined;

function forceWorkPlane() {
  currentWorkPlaneABC = undefined;
}

function setWorkPlane(abc) {
  if (!machineConfiguration.isMultiAxisConfiguration()) {
    return; // ignore
  }
  if (isInspectionOperation(currentSection) && !is3D()) {
    error(localize("Multi axis Inspect surface is not supported."));
    return;
  }
  forceWorkPlane(); // always need the new workPlane
  forceABC();

  writeBlock("MoveToSafetyPosition");
  writeBlock("Rapid" + aOutput.format(abc.x) + bOutput.format(abc.y) + cOutput.format(abc.z));

  currentWorkPlaneABC = abc;
}

var closestABC = false; // choose closest machine angles
var currentMachineABC;

function getWorkPlaneMachineABC(workPlane) {
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
    currentMachineABC = abc;
  } catch (e) {
    error(
      localize("Machine angles not supported") + ":"
      + conditional(machineConfiguration.isMachineCoordinate(0), " A" + abcFormat.format(abc.x))
      + conditional(machineConfiguration.isMachineCoordinate(1), " B" + abcFormat.format(abc.y))
      + conditional(machineConfiguration.isMachineCoordinate(2), " C" + abcFormat.format(abc.z)));
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
      + conditional(machineConfiguration.isMachineCoordinate(2), " C" + abcFormat.format(abc.z)));
  }

  var tcp = false;
  if (tcp) {
    setRotation(W); // TCP mode
  } else {
    var O = machineConfiguration.getOrientation(abc);
    var R = machineConfiguration.getRemainingOrientation(abc, W);
    setRotation(R);
  }

  return abc;
}

function onSection() {
  currentOperation = new NewOperation(getOperationName(currentSection));
  setWriteRedirection(currentOperation.operationProgram);

  var forceToolAndRetract = optionalSection && !currentSection.isOptional();
  optionalSection = currentSection.isOptional();

  if (!isProbeOperation(currentSection)) {
    writeComment("Operation Time: " + formatCycleTime(currentSection.getCycleTime()));
  }

  var showToolZMin = true;
  if (showToolZMin) {
    if (is3D()) {
      var zRange = currentSection.getGlobalZRange();
      var number = tool.number;
      zRange.expandToRange(currentSection.getGlobalZRange());
      writeComment("ZMIN = " + xyzFormat.format(zRange.getMinimum()));
    }
  }

  // create sub program
  writeBlock("program " + getOperationName(currentSection));
  spacingDepth += 1;

  if (passThrough) {
    var joinString = EOL + getSpacing();
    var passThroughString = passThrough.join(joinString);
    if (passThroughString != "") {
      writeBlock(passThroughString);
    }
    passThrough = [];
  }

  // this control structure allows us to show the user the operation from the CAM application as a block of within the whole program similarly to Heidenhain structure.
  writeBlock("BeginBlock name=" + "\"" + getOperationDescription(currentSection) + "\"");
  var operationTolerance = tolerance;
  if (hasParameter("operation:tolerance")) {
    operationTolerance = Math.max(getParameter("operation:tolerance"), 0);
  }
  // wcs
  currentWorkOffset = undefined; // force wcs output
  var workOffset = currentSection.workOffset;
  if (workOffset > 0) {
    if (workOffset != currentWorkOffset) {
      writeBlock("LoadWcs name=\"" + workOffset + "\"");
      currentWorkOffset = workOffset;
    }
  }
  if (getProperty("useSmoothing") && !currentSection.isMultiAxis() && !isProbeOperation(currentSection)) {
    writeBlock("Smoothing On allowedDeviation=" + xyzFormat.format(operationTolerance * 1.2));
  } else {
    writeBlock("Smoothing Off");
  }

  if (getProperty("useDynamic")) {
    var dynamic = 5;
    operationName = getOperationName(currentSection).toUpperCase();
    dynamicIndex = operationName.lastIndexOf("DYN");
    explicitDynamic = parseInt(operationName.substring(dynamicIndex + 3, dynamicIndex + 4), 5);
    if (!isNaN(explicitDynamic) && ((explicitDynamic > 0 && explicitDynamic < 6))) {
      writeBlock("Dynamic = " + explicitDynamic +  "  # Created from operation name");
      dynamic = explicitDynamic;
    } else {
      // set machine type specific dynamic sets
      switch (getProperty("machineType")) {
      case "NEO":
        dynamic = 5;
        break;
      case "MX":
      case "Cube":
        if (operationTolerance <= toPreciseUnit(0.04, MM)) {
          dynamic = 4;
        }
        if (operationTolerance <= toPreciseUnit(0.02, MM)) {
          dynamic = 3;
        }
        if (operationTolerance <= toPreciseUnit(0.005, MM)) {
          dynamic = 2;
        }
        if (operationTolerance <= toPreciseUnit(0.003, MM)) {
          dynamic = 1;
        }
        break;
      }
      writeBlock("Dynamic = " + dynamic);
    }
  }
  if (getProperty("waitAfterOperation")) {
    showWaitDialog(getOperationName(currentSection));
  }

  if (machineConfiguration.isMultiAxisConfiguration()) {
    if (currentSection.isMultiAxis()) {
      forceWorkPlane();
      cancelTransformation();
      var abc = currentSection.getInitialToolAxisABC();
      if ((getProperty("rotaryAxisSetup") != "NONE") && getProperty("useRtcp")) {
        writeBlock("Rtcp On");
      }
      writeBlock("MoveToSafetyPosition");
      forceABC();
      writeBlock("Rapid" + aOutput.format(abc.x) + bOutput.format(abc.y) + cOutput.format(abc.z));
    } else {
      forceWorkPlane();
      var abc = getWorkPlaneMachineABC(currentSection.workPlane);
      setWorkPlane(abc);
      if ((getProperty("rotaryAxisSetup") != "NONE") && getProperty("useRtcp")) {
        writeBlock("Rtcp On");
      }
    }
  } else {
    // pure 3D
    var remaining = currentSection.workPlane;
    if (!isSameDirection(remaining.forward, new Vector(0, 0, 1)) || currentSection.isMultiAxis()) {
      error("\r\n_________________________________________" +
         "\r\n|              error                     |" +
         "\r\n|                                        |" +
         "\r\n| Tool orientation detected.             |" +
         "\r\n| You have to specify your kinematic     |" +
         "\r\n| by using property 'Rotary axis setup', |" +
         "\r\n| otherwise you can only post            |" +
         "\r\n| 3 axis programs.                       |" +
         "\r\n| If you still have issues,              |" +
         "\r\n| please contact www.DATRON.com!         |" +
         "\r\n|________________________________________|\r\n");
      return;
    }
    setRotation(remaining);
  }
  
  forceAny();

  if (getProperty("showNotes") && currentSection.hasParameter("notes")) {
    var notes = currentSection.getParameter("notes");
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

  var clearance = getFramePosition(currentSection.getInitialPosition()).z;
  writeBlock("SafeZHeightForWorkpiece=" + xyzFormat.format(clearance));

  // write the optional length offset for each operation
  if (getProperty("useZAxisOffset")) {
    writeBlock("ZAxisOffset = 0");
  }

  // radius compensation
  var compensationType;
  if (hasParameter("operation:compensationType")) {
    compensationType = getParameter("operation:compensationType");
  } else {
    compensationType = "computer";
  }

  var wearCompensation;
  if (hasParameter("operation:compensationDeltaRadius")) {
    wearCompensation = getParameter("operation:compensationDeltaRadius");
  } else {
    wearCompensation = 0;
  }

  if (true /*getProperty("writePathOffset")*/) {
    switch (compensationType) {
    case "computer":
      break;
    case "control":
      writeBlock("PathOffset = 0");
      break;
    case "wear":
    case "inverseWear":
      writeBlock("PathOffset = " + dimensionFormat.format(wearCompensation));
      break;
    }
  }

  if (!isProbeOperation(currentSection) && !isInspectionOperation(currentSection)) {

    // set coolant after we have positioned at Z
    setCoolant(tool.coolant);

    // tool changer command
    if (getProperty("writeToolTable")) {
      writeBlock("Tool name=" + "\"" + createToolName(tool) + "\"" +
        " newRpm=" + rpmFormat.format(spindleSpeed) +
        " skipRestoring"
      );
    } else {
      writeBlock("Tool = " + toolOutput.format(tool.number) +
        " newRpm=" + rpmFormat.format(spindleSpeed) +
        " skipRestoring"
      );
    }

    // preload the next tool for the Datron tool assist
    if (getProperty("preloadTool")) {
      var nextTool = getNextTool(tool.number);
      if (nextTool) {
        if (getProperty("writeToolTable")) {
          writeBlock("ProvideTool name=" + "\"" + createToolName(nextTool) +  "\"");
        } else {
          writeBlock("ProvideTool = " + toolOutput.format(nextTool.number));
        }
      }
    }

    // set the current feed
    // replace by the default feed command
    if (getProperty("useParametricFeed") && !(currentSection.hasAnyCycle && currentSection.hasAnyCycle())) {
      activeFeeds = initializeActiveFeeds(currentSection);
      if (useDatronFeedCommand) {
        var datronFeedParameter = new Array();
        for (var j = 0; j < activeFeeds.length; ++j) {
          var feedContext = activeFeeds[j];
          var datronFeedCommand = {
            name : feedContext.datronFeedName,
            feed : feedFormat.format(feedContext.feed)
          };
/*eslint-disable*/
          var indexOfFeedContext = datronFeedParameter.map(function(e) {return e.name;}).indexOf(datronFeedCommand.name);
          /*eslint-enable*/
          if (indexOfFeedContext == -1) {
            datronFeedParameter.push(datronFeedCommand);
          } else {
            var existingFeedContext = datronFeedParameter[indexOfFeedContext];
            if (existingFeedContext.feed < datronFeedCommand.feed) {
              existingFeedContext.feed = datronFeedCommand.feed;
            }
          }
        }
        var datronFeedCommand = "SetFeedTechnology";
        for (var i = 0; i < datronFeedParameter.length; i++) {
          datronFeedCommand += " " + datronFeedParameter[i].name + "=" + datronFeedParameter[i].feed;
        }
        writeBlock(datronFeedCommand);

      } else {
        for (var j = 0; j < activeFeeds.length; ++j) {
          var feedContext = activeFeeds[j];
          writeBlock(formatVariable(feedContext.description) + " = " + feedFormat.format(feedContext.feed) + (unit == MM ? " # mm/min!" : " # in/min!"));
        }
      }
    }
  }

  // parameter for the sequences
  var sequenceParamter = new Array();

  if (hasParameter("operation:cycleType")) {
    // reset all movements to suppress older entries...
    activeMovements = new Array();
    var cycleType = getParameter("operation:cycleType");
    writeComment("Parameter " + cycleType + " cycle");
    var cycleFeedrate = currentSection.getParameter("feedrate");
    var cyclePlungeFeedrate = currentSection.getParameter("plungeFeedrate");
    var cycleRampingFeedrate = currentSection.getParameter("operation:tool_feedRamp");

    switch (cycleType) {
    case "thread-milling":
      writeBlock("SetFeedTechnology ramp=" + feedFormat.format(cycleRampingFeedrate) + " finishing=" + feedFormat.format(cycleFeedrate));
      var diameter = currentSection.getParameter("diameter");
      var pitch = currentSection.getParameter("pitch");
      var finishing = currentSection.getParameter("stepover");

      writeBlock("nominalDiameter=" + xyzFormat.format(diameter));
      sequenceParamter.push("nominalDiameter=nominalDiameter");
      writeBlock("pitch=" + xyzFormat.format(pitch));
      sequenceParamter.push("pitch=pitch");
      if (xyzFormat.isSignificant(parseInt(finishing, 10))) {
        writeBlock("finishing=" + xyzFormat.format(finishing));
        sequenceParamter.push("finishing=finishing");
      } else {
        sequenceParamter.push("finishing=0");
      }
      /*
      writeBlock('threadName="M' +  toolFormat.format(diameter) + '"');
      sequenceParamter.push('threadName=threadName');
      writeBlock("threading = " + currentSection.getParameter("threading"));
      sequenceParamter.push("threading=threading");

      TAG: den Standard auch mit Imperial unterstuezten
      sequenceParamter.push("threadStandard=ThreadStandards.Metric");
      sequenceParamter.push("deburring=ThreadMillingDeburring.NoDeburring");
      sequenceParamter.push("insideOutside=ThreadMillingSide.Inside");
      sequenceParamter.push("direction=ThreadMillingDirection.RightHandThread");
      writeBlock("direction = " + dimensionFormat.format(currentSection.getParameter("direction")));
      sequenceParamter.push("direction=direction");
      writeBlock("repeatPass = " + dimensionFormat.format(currentSection.getParameter("repeatPass")));
      sequenceParamter.push("repeatPass=repeatPass");
*/
      break;
    case "bore-milling":
      writeBlock("SetFeedTechnology roughing=" + feedFormat.format(cycleFeedrate) + " finishing=" + feedFormat.format(cycleFeedrate));
      writeBlock("diameter = " + dimensionFormat.format(currentSection.getParameter("diameter")));
      sequenceParamter.push("diameter=diameter");

      writeBlock("infeedZ = " + dimensionFormat.format(currentSection.getParameter("pitch")));
      sequenceParamter.push("infeedZ=infeedZ");
      writeBlock("repeatPass = " + dimensionFormat.format(currentSection.getParameter("repeatPass")));
      sequenceParamter.push("repeatPass=repeatPass");
      break;
    case "drilling":
      writeBlock("SetFeedTechnology plunge=" + feedFormat.format(cyclePlungeFeedrate));
      break;
    case "chip-breaking":
      writeBlock("SetFeedTechnology plunge=" + feedFormat.format(cyclePlungeFeedrate) + " roughing=" + feedFormat.format(cycleFeedrate));
      writeBlock("infeedZ = " + dimensionFormat.format(currentSection.getParameter("incrementalDepth")));
      sequenceParamter.push("infeedZ=infeedZ");
      break;
    }
  }

  if (getProperty("useSequences") && !isProbeOperation(currentSection) && !isInspectionOperation(currentSection)) {
    // call sequence
    if (getProperty("useParametricFeed") && (!useDatronFeedCommand) && !(currentSection.hasAnyCycle && currentSection.hasAnyCycle())) {
      activeFeeds = initializeActiveFeeds(currentSection);
      for (var j = 0; j < activeFeeds.length; ++j) {
        var feedContext = activeFeeds[j];
        sequenceParamter.push(formatVariable(feedContext.description) + "=" + formatVariable(feedContext.description));
      }
    }
    var currentSectionCall = getSequenceName(currentSection) + " " + sequenceParamter.join(" ");
    writeBlock(currentSectionCall);

    // write sequence
    var currentSequenceName = getSequenceName(currentSection);
    if (getProperty("useExternalSequencesFiles")) {
      spacingDepth -= 1;
      var filename = getOutputPath();
      // sequenceFilePath = filename.substr(0, filename.lastIndexOf(".")) + "_" + currentSequenceName + ".seq";
      sequenceFilePath = FileSystem.getFolderPath(getOutputPath()) + "\\";
      sequenceFilePath += currentSequenceName + ".seq";
      redirectToFile(sequenceFilePath);
    } else {
      setWriteRedirection(sequenceBuffer);
      writeBlock(" ");
      // TAG: modify parameter
      spacingDepth -= 1;
      writeBlock("$$$ " + currentSequenceName);
    }
  }

  if (!isProbeOperation(currentSection) && !isInspectionOperation(currentSection)) {
    writeBlock(spindleSpeed > 100 ? "Spindle On" : "Spindle Off");
  } else {
    writeBlock("Spindle Off");
    writeBlock("PrepareXyzSensor");
  }

  // move to initial Position (this command move the Z Axis to safe high and repositioning in safe high after that drive Z to end position)
  var initialPosition = getFramePosition(currentSection.getInitialPosition());
  var xyz = xOutput.format(initialPosition.x) + yOutput.format(initialPosition.y) + zOutput.format(initialPosition.z);
  writeBlock("PrePositioning" + xyz);

  if (getProperty("useSuction")) {
    writeBlock("Suction On");
  }
  // surface Inspection
  if (isInspectionOperation(currentSection) && (typeof inspectionProcessSectionStart == "function")) {
    inspectionProcessSectionStart();
  }
  
}

function showWaitDialog(operationName) {
  writeBlock("showWaitDialog operationName=\"" + operationName + "\"");
}

function writeWaitProgram() {
  waitProgram = new Array();
  waitProgram =
    ["#Show the wait dialog for the next operation",
      "  if not operationName hasvalue",
      "    operationName =" + "\"" + "\"",
      "  endif",
      "",
      "  messageString = " + "\"" + "Start next Operation\r"  + "\"" + "  + operationName",
      "  dialogRes = System::Dialog message=messageString caption=" + "\"" + "Start next Operation?" + "\"" + "Yes  Cancel",
      "  if dialogRes == System::DialogResult.Cancel",
      "    exit",
      "  endif",
      "endprogram"
    ];
  waitProgramOperation = {operationProgram: waitProgram.join(EOL)};
  SimPLProgram.operationList.push(waitProgramOperation);
}

function onDwell(seconds) {
  writeBlock("Sleep " + "milliseconds=" + sleepFormat.format(seconds));
}

function onSpindleSpeed(spindleSpeed) {
  writeBlock("Rpm=" + rpmFormat.format(spindleSpeed));
}

var pendingRadiusCompensation = -1;

function onRadiusCompensation() {
  pendingRadiusCompensation = radiusCompensation;
}

function onRapid(x, y, z) {
  var xyz = "";
  xyz += (x !== null) ? xOutput.format(x) : "";
  xyz += (y !== null) ? yOutput.format(y) : "";
  xyz += (z !== null) ? zOutput.format(z) : "";

  if (xyz) {
    if (pendingRadiusCompensation >= 0) {
      error(localize("Radius compensation mode cannot be changed at rapid traversal."));
      return;
    }
    writeBlock("Rapid" + xyz);
    forceFeed();
  }
}

function onPrePositioning(x, y, z) {
  var xyz = "";
  xyz += (x !== null) ? xOutput.format(x) : "";
  xyz += (y !== null) ? yOutput.format(y) : "";
  xyz += (z !== null) ? zOutput.format(z) : "";

  if (xyz) {
    if (pendingRadiusCompensation >= 0) {
      error(localize("Radius compensation mode cannot be changed at rapid traversal."));
      return;
    }
    writeBlock("PrePositioning" + xyz);
    forceFeed();
  }
}

function onLinear(x, y, z, feed) {
  if (isInspectionOperation(currentSection)) {
    onExpandedRapid(x, y, z);
    return;
  }
  var xyz = "";
  xyz += (x !== null) ? xOutput.format(x) : "";
  xyz += (y !== null) ? yOutput.format(y) : "";
  xyz += (z !== null) ? zOutput.format(z) : "";

  var f = getFeed(feed);

  if (pendingRadiusCompensation >= 0) {
    pendingRadiusCompensation = -1;
    var d = tool.diameterOffset;
    if (d > 99) {
      warning(localize("The diameter offset exceeds the maximum value."));
    }
    var compensationType = undefined;
    if (currentSection.hasParameter("operation:compensationType")) {
      compensationType = currentSection.getParameter("operation:compensationType");
    }

    switch (radiusCompensation) {
    case RADIUS_COMPENSATION_LEFT:
      switch (compensationType) {
      case "control":
        writeBlock("ToolCompensation Left");
        writeBlock("PathCorrection Left");
        break;
      case "wear":
      case "inverseWear":
        writeBlock("PathCorrection Left");
        break;
      default:
        writeBlock("ToolCompensation Off");
        writeBlock("PathCorrection Off");
        break;
      }
      break;
    case RADIUS_COMPENSATION_RIGHT:
      switch (compensationType) {
      case "control":
        writeBlock("ToolCompensation Right");
        writeBlock("PathCorrection Right");
        break;
      case "wear":
      case "inverseWear":
        writeBlock("PathCorrection Right");
        break;
      default:
        writeBlock("ToolCompensation Off");
        writeBlock("PathCorrection Off");
        break;
      }
      break;
    case RADIUS_COMPENSATION_OFF:
      writeBlock("ToolCompensation Off");
      writeBlock("PathCorrection Off");
      break;
    }
  }

  if (xyz) {
    if (f) {
      writeBlock(f);
    }
    writeBlock("Line" + xyz);
  }
}

function onCircular(clockwise, cx, cy, cz, x, y, z, feed) {
  // one of X/Y and I/J are required and likewise
  var f = getFeed(feed);

  if (f) {
    writeBlock(f);
  }

  if (pendingRadiusCompensation >= 0) {
    error(localize("Radius compensation cannot be activated/deactivated for a circular move."));
    return;
  }

  var start = getCurrentPosition();

  if (isFullCircle()) {
    if (isHelical()) {
      linearize(tolerance);
      return;
    }
    // TAG: are 360deg arcs supported
    switch (getCircularPlane()) {
    case PLANE_XY:
      writeBlock("Arc" +
        (clockwise ? " CW" : " CCW") +
        xOutput.format(x) +
        iOutput.format(cx - start.x) +
        jOutput.format(cy - start.y)
      );
      break;
    default:
      linearize(tolerance);
    }
  } else {
    switch (getCircularPlane()) {
    case PLANE_XY:
      writeBlock("Arc" +
        (clockwise ? " CW" : " CCW") +
        xOutput.format(x) +
        yOutput.format(y) +
        zOutput.format(z) +
        iOutput.format(cx - start.x) +
        jOutput.format(cy - start.y)
      );
      break;
    default:
      linearize(tolerance);
    }
  }
}

function onRapid5D(_x, _y, _z, _a, _b, _c) {
  if (pendingRadiusCompensation >= 0) {
    error(localize("Radius compensation mode cannot be changed at rapid traversal."));
    return;
  }
  var x = xOutput.format(_x);
  var y = yOutput.format(_y);
  var z = zOutput.format(_z);
  var a = aOutput.format(_a);
  var b = bOutput.format(_b);
  var c = cOutput.format(_c);

  forceABC();
  var xyzabc = x + y + z + a + b + c;
  writeBlock("Rapid" + xyzabc);
  forceFeed();
}

function onLinear5D(_x, _y, _z, _a, _b, _c, feed) {
  if (pendingRadiusCompensation >= 0) {
    error(localize("Radius compensation cannot be activated/deactivated for 5-axis move."));
    return;
  }
  var x = xOutput.format(_x);
  var y = yOutput.format(_y);
  var z = zOutput.format(_z);
  var a = aOutput.format(_a);
  var b = bOutput.format(_b);
  var c = cOutput.format(_c);
  var f = getFeed(feed);

  writeBlock(f);
  if (x || y || z || a || b || c) {
    var xyzabc = x + y + z + a + b + c;
    writeBlock("Line" + xyzabc);
  }
}

function onRewindMachine(a, b, c) {
  writeBlock("MoveToSafetyPosition");
  var abc = aOutput.format(a) + bOutput.format(b) + cOutput.format(c);
  writeBlock("Line" + abc);
}

var currentCoolantMode = COOLANT_OFF;

function setCoolant(coolant) {
  if (getProperty("writeCoolantCommands")) {
    if (coolant == COOLANT_OFF) {
      writeBlock("SpraySystem Off");
      currentCoolantMode = COOLANT_OFF;
      return;
    }

    switch (coolant) {
    case COOLANT_FLOOD:
    case COOLANT_MIST:
      writeBlock("SprayTechnology External");
      writeBlock("Coolant Alcohol");
      break;
    case COOLANT_AIR:
      writeBlock("SprayTechnology External");
      writeBlock("Coolant Air");
      break;
    case COOLANT_THROUGH_TOOL:
      writeBlock("SprayTechnology Internal");
      writeBlock("Coolant Alcohol");
      break;
    case COOLANT_AIR_THROUGH_TOOL:
      writeBlock("SprayTechnology Internal");
      writeBlock("Coolant Air");
      break;
      
    default:
      onUnsupportedCoolant(coolant);
    }
    writeBlock("SpraySystem On");
    currentCoolantMode = coolant;
  }
}

/*
var isInsideProgramDeclaration = false;
var directNcOperation;
function parseManualNc(text) { // todo
  var modulePattern = new RegExp(".*(using|import)");
  var isModuleImport = modulePattern.test(text);
  if (isModuleImport) {
    SimPLProgram.usingList.push(text);
    return;
  }
 
  var programPattern = /(?:\s*program\s+)(\w+)/;
  var isProgramDeclaration = programPattern.test(text);
  if (isProgramDeclaration) {
    var subProgramName =  programPattern.exec(text);
    if (subProgramName == undefined) {
      return;
    }
    directNcOperation = {operationCall:subProgramName[1], operationProgram: new StringBuffer()};
    SimPLProgram.operationList.push(directNcOperation);
    isInsideProgramDeclaration = true;
  }

  var isEndProgram = (/\s*endprogram/).test(text);
  if (isEndProgram) {
    isInsideProgramDeclaration = false;
    directNcOperation.operationProgram.append(text + EOL);
    return;
  }

  if (isInsideProgramDeclaration) {
    directNcOperation.operationProgram.append(text + EOL);
    return;
  }
  return;
}
*/

function onManualNC(command, value) {
  if (command == COMMAND_PASS_THROUGH) {
    error(localize("Manual NC pass through is currently not supported."));
    return;
  }
  switch (command) {
  // case COMMAND_PASS_THROUGH:
  //   value = parseManualNc(value);
  //   break;
  case COMMAND_COMMENT:
    value = "# " + value;
    break;
  case COMMAND_DWELL:
    value = "Sleep seconds=" + value;
    break;
  case COMMAND_COOLANT_OFF:
    value = "SpraySystem Off";
    break;
  case COMMAND_COOLANT_ON:
    value = "SpraySystem On";
    break;
  case COMMAND_STOP:
    value = "break";
    break;
  case COMMAND_START_SPINDLE:
    value = "Spindle On";
    break;
  case COMMAND_LOCK_MULTI_AXIS:
    return;
  case COMMAND_UNLOCK_MULTI_AXIS:
    return;
  case COMMAND_START_CHIP_TRANSPORT:
    value = "ChipConveyor On";
    break;
  case COMMAND_STOP_CHIP_TRANSPORT:
    value = "ChipConveyor Off";
    break;
  case COMMAND_OPEN_DOOR:
    value = "ReleaseDoor";
    break;
  case COMMAND_CLOSE_DOOR:
    return;
  case COMMAND_CALIBRATE:
    value = "# calibration currently not supported!";
    break;
  case COMMAND_VERIFY:
    value = "Dialog message=\"Please check workpiece!\" Ok Cancel caption=\"Cam generated dialog\"";
    break;
  case COMMAND_CLEAN:
    value = "Dialog message=\"Please clean workpiece!\" Ok Cancel caption=\"Cam generated dialog\"";
    break;
  case COMMAND_ACTION:
    value = "# Action currently not supported!";
    break;
  case COMMAND_PRINT_MESSAGE:
    // value = 'Dialog message="' + value + '" Ok Cancel caption="Cam generated dialog"'
    SimPLProgram.usingList.push("using File");
    SimPLProgram.usingList.push("using DateTimeModule");
    var message = (" value=(GetNow + \"\t" + value + "\")");
    value = "FileWriteLine filename=\"" + getProgramFilename() + ".log\""  + message;
    break;
  case COMMAND_DISPLAY_MESSAGE:
    value = "StatusMessage message=\"" + value + "\"";
    break;
  case COMMAND_ALARM:
    value = "Dialog message=\"Alarm!\" Ok Cancel caption=\"Cam generated dialog\"";
    break;
  case COMMAND_ALERT:
    value = "Dialog message=\"Warning!\" Ok Cancel caption=\"Cam generated dialog\"";
    break;
  case COMMAND_BREAK_CONTROL:
    value = "MeasureToolLength";
    break;
  case COMMAND_TOOL_MEASURE:
    value = "MeasureToolLength";
    break;
  case COMMAND_OPTIONAL_STOP:
    value = "OptionalBreak";
    break;
  case COMMAND_CALL_PROGRAM:
    var subprogramName = "SubProgram_" + SimPLProgram.externalUsermodules.length;
    SimPLProgram.externalUsermodules.push("usermodule " + subprogramName + "=\"" + value + "\"");
    value = subprogramName;
    break;
  }

  if (value != undefined) {
    var operation = {operationCall: value, operationProgram:""};
    SimPLProgram.operationList.push(operation);
  }
}

var mapCommand = {};

var passThrough = new Array();
function onPassThrough(text) {
  passThrough.push(text);
}

function onCommand(command) {
  switch (command) {
  case COMMAND_PROBE_ON:
    return;
  case COMMAND_PROBE_OFF:
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

function onCycle() {
}

function onCycleEnd() {
}

function isProbeOperation(section) {
  return section.hasParameter("operation-strategy") && ((section.getParameter("operation-strategy") == "probe" || section.getParameter("operation-strategy") == "probe_geometry"));
}

function isInspectionOperation(section) {
  return section.hasParameter("operation-strategy") && (section.getParameter("operation-strategy") == "inspectSurface");
}

function approach(value) {
  validate((value == "positive") || (value == "negative"), "Invalid approach.");
  return (value == "positive") ? 1 : -1;
}

function onCyclePoint(x, y, z) {
  if (hasParameter("operation-strategy") && (getParameter("operation-strategy") == "probe_geometry")) {
    error(localize("Probe Geometry is not supported."));
    return;
  }
  if (cycleType == "inspect") {
    if (typeof inspectionCycleInspect == "function") {
      inspectionCycleInspect(cycle, x, y, z);
      return;
    } else {
      cycleNotSupported();
    }
  }
  var feedString = feedOutput.format(cycle.feedrate);
  var probeWCS = hasParameter("operation-strategy") && (getParameter("operation-strategy") == "probe");

  if (isProbeOperation(currentSection)) {
    if (!isSameDirection(currentSection.workPlane.forward, new Vector(0, 0, 1)) && (!cycle.probeMode || (cycle.probeMode == 0))) {
      error(localize("Updating WCS / work offset using probing is only supported by the CNC in the WCS frame."));
      return;
    }
    forceXYZ();
    onPrePositioning(x, y, z); // TAG would be needed for probeMultipleFeatures, but generates duplicated Prepositioning output, acceptable?
    var startPositionOffset = cycle.probeClearance + tool.cornerRadius;
  }

  switch (cycleType) {
  case "bore-milling":
    for (var i = 0; i <= cycle.repeatPass; ++i) {
      forceXYZ();
      onExpandedRapid(x, y, cycle.clearance);
      boreMilling(cycle);
      onExpandedRapid(x, y, cycle.clearance);
    }
    break;
  case "thread-milling":
    for (var i = 0; i <= cycle.repeatPass; ++i) {
      forceXYZ();
      onExpandedRapid(x, y, cycle.clearance);
      threadMilling(cycle);
      onExpandedRapid(x, y, cycle.clearance);
    }
    break;
  case "drilling":
    forceXYZ();
    onExpandedRapid(x, y, cycle.clearance);
    drilling(cycle);
    onExpandedRapid(x, y, cycle.clearance);
    break;
    /*
  case "chip-breaking":
    forceXYZ();
    onExpandedRapid(x, y, null);
    onExpandedRapid(x, y, cycle.retract);
    chipBreaking(cycle);
    onExpandedRapid(x, y, cycle.clearance);
    break;
*/

  case "tapping":
  case "left-tapping":
  case "right-tapping":
  case "tapping-with-chip-breaking":
  case "left-tapping-with-chip-breaking":
  case "right-tapping-with-chip-breaking":
    forceXYZ();
    onExpandedRapid(x, y, cycle.clearance);
    tapping(cycle);
    onExpandedRapid(x, y, cycle.clearance);
    break;
  case "probing-x":
    forceXYZ();
    onExpandedRapid(x, y, cycle.stock);
    onExpandedLinear(x, y, (z - cycle.depth + tool.cornerRadius), cycle.feedrate);
   
    var measureString = "measResult = EdgeMeasure ";
    measureString += (cycle.approach1 == "positive" ? "XPositive" : "XNegative");
    measureString += " searchDistance=" + xyzFormat.format(cycle.probeClearance);
    if (probeWCS) {
      measureString += " originShift=" + xyzFormat.format(-1 * (x + approach(cycle.approach1) * startPositionOffset));
      writeBlock(measureString);
    } else {
      measureString += " None";
      writeBlock(measureString);
      expectedArgs = "expectedXPos=" +  xyzFormat.format(x + approach(cycle.approach1) * startPositionOffset) +
        " measureDirectionX=" + (cycle.approach1 == "positive" ? "positive" : "negative");
      writeBlock(getProbingArguments(cycle, undefined, expectedArgs));
    }
    break;
  case "probing-y":
    forceXYZ();
    onExpandedRapid(x, y, cycle.stock);
    onExpandedLinear(x, y, (z - cycle.depth + tool.cornerRadius), cycle.feedrate);
    
    var measureString = "measResult = EdgeMeasure ";
    measureString += (cycle.approach1 == "positive" ? "YPositive" : "YNegative");
    measureString += " searchDistance=" + xyzFormat.format(cycle.probeClearance);
    if (probeWCS) {
      measureString += " originShift=" + xyzFormat.format(-1 * (y + approach(cycle.approach1) * startPositionOffset));
      writeBlock(measureString);
    } else {
      measureString += " None";
      writeBlock(measureString);
      expectedArgs = "expectedYPos=" + xyzFormat.format(y + approach(cycle.approach1) * startPositionOffset) +
        " measureDirectionY=" + (cycle.approach1 == "positive" ? "positive" : "negative");
      writeBlock(getProbingArguments(cycle, undefined, expectedArgs));
    }
    break;
  case "probing-z":
    forceXYZ();
    onExpandedRapid(x, y, cycle.stock);
    onExpandedLinear(x, y, (Math.min(z - cycle.depth + cycle.probeClearance, cycle.retract)), cycle.feedrate);
  
    var measureString = "measResult = SurfaceMeasure ";
    if (probeWCS) {
      measureString += " originZShift=" + xyzFormat.format(z - cycle.depth);
      writeBlock(measureString);
    } else {
      measureString += " None";
      writeBlock(measureString);
      expectedArgs = "expectedZPos=" + xyzFormat.format(z - cycle.depth);
      writeBlock(getProbingArguments(cycle, undefined, expectedArgs));
    }
    break;
  case "probing-x-wall":
    var measureString = "measResult = SymmetryAxisMeasure";
    measureString += " width=" + xyzFormat.format(cycle.width1);
    measureString += " searchDistance=" + xyzFormat.format(cycle.probeClearance);
    measureString += " measureZOffset=" + xyzFormat.format((z - cycle.depth + tool.diameter / 2));
    measureString += " Outside";
    measureString += " YAligned";
    measureString += " skipZMeasure";
    if (probeWCS) {
      measureString += " originXShift=" + xyzFormat.format(-x);
      writeBlock(measureString);
    } else {
      measureString += " None";
      writeBlock(measureString);
      expectedArgs = "expectedXPos=" + xyzFormat.format(x) +
        " expectedDimensionX=" + xyzFormat.format(cycle.width1);
      writeBlock(getProbingArguments(cycle, undefined, expectedArgs));
    }
    break;
  case "probing-y-wall":
    var measureString = "measResult = SymmetryAxisMeasure";
    measureString += " width=" + xyzFormat.format(cycle.width1);
    measureString += " searchDistance=" + xyzFormat.format(cycle.probeClearance);
    measureString += " measureZOffset=" + xyzFormat.format((z - cycle.depth + tool.diameter / 2));
    measureString += " Outside";
    measureString += " XAligned";
    measureString += " skipZMeasure";
    if (probeWCS) {
      measureString += " originYShift=" + xyzFormat.format(-y);
      writeBlock(measureString);
    } else {
      measureString += " None";
      writeBlock(measureString);
      expectedArgs = "expectedYPos=" + xyzFormat.format(y) +
        " expectedDimensionY=" + xyzFormat.format(cycle.width1);
      writeBlock(getProbingArguments(cycle, undefined, expectedArgs));
    }
    break;
  case "probing-x-channel":
    var measureString = "measResult = SymmetryAxisMeasure";
    measureString += " width=" + xyzFormat.format(cycle.width1);
    measureString += " searchDistance=" + xyzFormat.format(cycle.probeClearance);
    measureString += " measureZOffset=" + xyzFormat.format((z - cycle.depth + tool.diameter / 2));
    measureString += " Inside";
    measureString += " YAligned";
    measureString += " skipZMeasure";
    if (probeWCS) {
      measureString += " originXShift=" + xyzFormat.format(-x);
      writeBlock(measureString);
    } else {
      measureString += " None";
      writeBlock(measureString);
      expectedArgs = "expectedXPos=" + xyzFormat.format(x) +
        " expectedDimensionX=" + xyzFormat.format(cycle.width1);
      writeBlock(getProbingArguments(cycle, undefined, expectedArgs));
    }
    break;
  case "probing-x-channel-with-island":
    var measureString = "measResult = SymmetryAxisMeasure";
    measureString += " width=" + xyzFormat.format(cycle.width1);
    measureString += " searchDistance=" + xyzFormat.format(cycle.probeClearance);
    measureString += " measureZOffset=" + xyzFormat.format((z - cycle.depth + tool.diameter / 2));
    measureString += " Inside";
    measureString += " YAligned";
    measureString += " forceSafeHeight";
    measureString += " skipZMeasure";
    if (probeWCS) {
      measureString += " originXShift=" + xyzFormat.format(-x);
      writeBlock(measureString);
    } else {
      measureString += " None";
      writeBlock(measureString);
      expectedArgs = "expectedXPos=" + xyzFormat.format(x) +
        " expectedDimensionX=" + xyzFormat.format(cycle.width1);
      writeBlock(getProbingArguments(cycle, undefined, expectedArgs));
    }
    break;
  case "probing-y-channel":
    var measureString = "measResult = SymmetryAxisMeasure";
    measureString += " width=" + xyzFormat.format(cycle.width1);
    measureString += " searchDistance=" + xyzFormat.format(cycle.probeClearance);
    measureString += " measureZOffset=" + xyzFormat.format((z - cycle.depth + tool.diameter / 2));
    measureString += " Inside";
    measureString += " XAligned";
    measureString += " skipZMeasure";
    if (probeWCS) {
      measureString += " originYShift=" + xyzFormat.format(-y);
      writeBlock(measureString);
    } else {
      measureString += " None";
      writeBlock(measureString);
      expectedArgs = "expectedYPos=" + xyzFormat.format(y) +
        " expectedDimensionY=" + xyzFormat.format(cycle.width1);
      writeBlock(getProbingArguments(cycle, undefined, expectedArgs));
    }
    break;
  case "probing-y-channel-with-island":
    var measureString = "measResult = SymmetryAxisMeasure";
    measureString += " width=" + xyzFormat.format(cycle.width1);
    measureString += " searchDistance=" + xyzFormat.format(cycle.probeClearance);
    measureString += " measureZOffset=" + xyzFormat.format((z - cycle.depth + tool.diameter / 2));
    measureString += " Inside";
    measureString += " XAligned";
    measureString += " forceSafeHeight";
    measureString += " skipZMeasure";
    if (probeWCS) {
      measureString += " originYShift=" + xyzFormat.format(-y);
      writeBlock(measureString);
    } else {
      measureString += " None";
      writeBlock(measureString);
      expectedArgs = "expectedYPos=" + xyzFormat.format(y) +
        " expectedDimensionY=" + xyzFormat.format(cycle.width1);
      writeBlock(getProbingArguments(cycle, undefined, expectedArgs));
    }
    break;
  case "probing-xy-circular-boss":
    var measureString = "measResult = CircleMeasure";
    measureString += " diameter=" + xyzFormat.format(cycle.width1);
    measureString += " searchDistance=" + xyzFormat.format(cycle.probeClearance);
    measureString += " measureZPos=" + xyzFormat.format((z - cycle.depth + tool.diameter / 2));
    measureString += " Outside";
    measureString += " skipZMeasure";
    if (probeWCS) {
      measureString += " originXShift=" + xyzFormat.format(-x);
      measureString += " originYShift=" + xyzFormat.format(-y);
      writeBlock(measureString);
    } else {
      measureString += " None";
      writeBlock(measureString);
      expectedArgs = "expectedXPos=" +  xyzFormat.format(x) +
        " expectedYPos=" + xyzFormat.format(y) +
        " expectedDimensionX=" + xyzFormat.format(cycle.width1);
      writeBlock(getProbingArguments(cycle, undefined, expectedArgs));
    }
    break;
  case "probing-xy-circular-hole":
    var measureString = "measResult = CircleMeasure";
    measureString += " diameter=" + xyzFormat.format(cycle.width1);
    measureString += " searchDistance=" + xyzFormat.format(cycle.probeClearance);
    measureString += " measureZPos=" + xyzFormat.format((z - cycle.depth + tool.diameter / 2));
    measureString += " Inside";
    measureString += " skipZMeasure";
    if (probeWCS) {
      measureString += " originXShift=" + xyzFormat.format(-x);
      measureString += " originYShift=" + xyzFormat.format(-y);
      writeBlock(measureString);
    } else {
      measureString += " None";
      writeBlock(measureString);
      expectedArgs = "expectedXPos=" +  xyzFormat.format(x) +
        " expectedYPos=" + xyzFormat.format(y) +
        " expectedDimensionX=" + xyzFormat.format(cycle.width1);
      writeBlock(getProbingArguments(cycle, undefined, expectedArgs));
    }
    break;
  case "probing-xy-circular-hole-with-island":
    var measureString = "measResult = CircleMeasure";
    measureString += " diameter=" + xyzFormat.format(cycle.width1);
    measureString += " searchDistance=" + xyzFormat.format(cycle.probeClearance);
    measureString += " measureZPos=" + xyzFormat.format((z - cycle.depth + tool.diameter / 2));
    measureString += " Inside";
    measureString += " forceSafeHeight";
    measureString += " skipZMeasure";
    if (probeWCS) {
      measureString += " originXShift=" + xyzFormat.format(-x);
      measureString += " originYShift=" + xyzFormat.format(-y);
      writeBlock(measureString);
    } else {
      measureString += " None";
      writeBlock(measureString);
      expectedArgs = "expectedXPos=" +  xyzFormat.format(x) +
        " expectedYPos=" + xyzFormat.format(y) +
        " expectedDimensionX=" + xyzFormat.format(cycle.width1);
      writeBlock(getProbingArguments(cycle, undefined, expectedArgs));
    }
    break;
  case "probing-xy-rectangular-boss":
    var measureString = "measResult = RectangleMeasure";
    measureString += " dimensionX=" + xyzFormat.format(cycle.width1);
    measureString += " dimensionY=" + xyzFormat.format(cycle.width2);
    measureString += " searchDistance=" + xyzFormat.format(cycle.probeClearance);
    measureString += " xMeasureZOffset=" + xyzFormat.format((z - cycle.depth + tool.diameter / 2));
    measureString += " yMeasureZOffset=" + xyzFormat.format((z - cycle.depth + tool.diameter / 2));
    measureString += " Outside";
    measureString += " Center";
    measureString += " skipZMeasure";
    if (probeWCS) {
      measureString += " originXShift=" + xyzFormat.format(-x);
      measureString += " originYShift=" + xyzFormat.format(-y);
      writeBlock(measureString);
    } else {
      measureString += " None";
      writeBlock(measureString);
      expectedArgs = "expectedXPos=" +  xyzFormat.format(x) +
        " expectedYPos=" + xyzFormat.format(y) +
        " expectedDimensionX=" + xyzFormat.format(cycle.width1) +
        " expectedDimensionY=" + xyzFormat.format(cycle.width2);
      writeBlock(getProbingArguments(cycle, undefined, expectedArgs));
    }
    break;
  case "probing-xy-rectangular-hole":
    var measureString = "measResult = RectangleMeasure";
    measureString += " dimensionX=" + xyzFormat.format(cycle.width1);
    measureString += " dimensionY=" + xyzFormat.format(cycle.width2);
    measureString += " searchDistance=" + xyzFormat.format(cycle.probeClearance);
    measureString += " xMeasureZOffset=" + xyzFormat.format((z - cycle.depth + tool.diameter / 2));
    measureString += " yMeasureZOffset=" + xyzFormat.format((z - cycle.depth + tool.diameter / 2));
    measureString += " Inside";
    measureString += " Center";
    measureString += " skipZMeasure";
    if (probeWCS) {
      measureString += " originXShift=" + xyzFormat.format(-x);
      measureString += " originYShift=" + xyzFormat.format(-y);
      writeBlock(measureString);
    } else {
      measureString += " None";
      writeBlock(measureString);
      expectedArgs = "expectedXPos=" +  xyzFormat.format(x) +
        " expectedYPos=" + xyzFormat.format(y) +
        " expectedDimensionX=" + xyzFormat.format(cycle.width1) +
        " expectedDimensionY=" + xyzFormat.format(cycle.width2);
      writeBlock(getProbingArguments(cycle, undefined, expectedArgs));
    }
    break;
  case "probing-xy-rectangular-hole-with-island":
    var measureString = "measResult = RectangleMeasure";
    measureString += " dimensionX=" + xyzFormat.format(cycle.width1);
    measureString += " dimensionY=" + xyzFormat.format(cycle.width2);
    measureString += " searchDistance=" + xyzFormat.format(cycle.probeClearance);
    measureString += " xMeasureZOffset=" + xyzFormat.format((z - cycle.depth + tool.diameter / 2));
    measureString += " yMeasureZOffset=" + xyzFormat.format((z - cycle.depth + tool.diameter / 2));
    measureString += " Inside";
    measureString += " Center";
    measureString += " forceSafeHeight";
    measureString += " skipZMeasure";
    if (probeWCS) {
      measureString += " originXShift=" + xyzFormat.format(-x);
      measureString += " originYShift=" + xyzFormat.format(-y);
      writeBlock(measureString);
    } else {
      measureString += " None";
      writeBlock(measureString);
      expectedArgs = "expectedXPos=" +  xyzFormat.format(x) +
        " expectedYPos=" + xyzFormat.format(y) +
        " expectedDimensionX=" + xyzFormat.format(cycle.width1) +
        " expectedDimensionY=" + xyzFormat.format(cycle.width2);
      writeBlock(getProbingArguments(cycle, undefined, expectedArgs));
    }
    break;
  case "probing-xy-inner-corner":
    /*
    var probingDepth = (z - cycle.depth + tool.cornerRadius);
    var measureString = "measResult = EdgeMeasure ";
    zOutput.reset();
    onExpandedRapid(x, y, cycle.stock);
    onExpandedLinear(x, y, probingDepth, cycle.feedrate);
    measureString += (cycle.approach1 == "positive" ? "XPositive" : "XNegative");
    measureString += " originShift=" + xyzFormat.format(-1 * (x + approach(cycle.approach1) * startPositionOffset));
    measureString += " searchDistance=" + xyzFormat.format(cycle.probeClearance);
    writeBlock(measureString);
    forceXYZ();
    //zOutput.reset();
    onExpandedRapid(x, y, cycle.stock);
    onExpandedLinear(x, y, probingDepth, cycle.feedrate);
    var measureString = "measResult = EdgeMeasure ";
    measureString += (cycle.approach1 == "positive" ? "YPositive" : "YNegative");
    measureString += " originShift=" + xyzFormat.format(-1 * (y + approach(cycle.approach1) * startPositionOffset));
    measureString += " searchDistance=" + xyzFormat.format(cycle.probeClearance);
    writeBlock(measureString);
    */
    var isXNegative = (cycle.approach1 == "negative");
    var isYNegative = (cycle.approach2 == "negative");
    
    var orientation = "";

    if (isXNegative) {
      orientation = isYNegative ? "FrontLeft" : "BackLeft";
    } else {
      orientation = isYNegative ? "FrontRight" : "BackRight";
    }

    var measureString = "measResult = CornerMeasure";
    measureString += " " + orientation;
    measureString += " Inside";
    measureString += " xMeasureYOffset=" + xyzFormat.format(cycle.probeClearance);
    measureString += " yMeasureXOffset=" + xyzFormat.format(cycle.probeClearance);
    measureString += " searchDistance=" + xyzFormat.format(cycle.probeClearance);
    measureString += " xMeasureZOffset=" + xyzFormat.format((z - cycle.depth + tool.diameter / 2));
    measureString += " yMeasureZOffset=" + xyzFormat.format((z - cycle.depth + tool.diameter / 2));
    measureString += " forceSafeHeight";
    measureString += " skipZMeasure";
    if (probeWCS) {
      measureString += " originXShift=" + xyzFormat.format(-x);
      measureString += " originYShift=" + xyzFormat.format(-y);
      writeBlock(measureString);
    } else {
      measureString += " None";
      writeBlock(measureString);
      expectedArgs = "expectedXPos=" +  xyzFormat.format(x) +
        " expectedYPos=" + xyzFormat.format(y) +
        " measureDirectionX=" + cycle.approach1 +
        " measureDirectionY=" + cycle.approach2;
      writeBlock(getProbingArguments(cycle, undefined, expectedArgs));
    }
    break;
  case "probing-xy-outer-corner":
    /*
    var probingDepth = (z - cycle.depth + tool.cornerRadius);
    var touchPositionX1 = x + approach(cycle.approach1) * (cycle.probeClearance + tool.diameter / 2 + cycle.probeOvertravel);
    var touchPositionY1 = y + approach(cycle.approach2) * (cycle.probeClearance + tool.diameter / 2 + cycle.probeOvertravel);
    var measureString = "measResult = EdgeMeasure ";
    zOutput.reset();
    onExpandedRapid(x, y, probingDepth);
    onExpandedLinear(x, touchPositionY1, probingDepth, cycle.feedrate);
    measureString += (cycle.approach1 == "positive" ? "XPositive" : "XNegative");
    measureString += " originShift=" + xyzFormat.format(-1 * (x + approach(cycle.approach1) * startPositionOffset));
    measureString += " searchDistance=" + xyzFormat.format(cycle.probeClearance);
    writeBlock(measureString);
    forceXYZ();
    onExpandedLinear(x, touchPositionY1, probingDepth, cycle.feedrate);
    onExpandedLinear(x, y, probingDepth, cycle.feedrate);
    //forceXYZ();
    //zOutput.reset();
    onExpandedLinear(touchPositionX1, y, probingDepth, cycle.feedrate);
    onExpandedLinear(touchPositionX1, y, probingDepth, cycle.feedrate);
    */
    var touchPositionX1 = x + approach(cycle.approach1) * (cycle.probeClearance + tool.diameter / 2 + cycle.probeOvertravel);
    var probingDepth = (z - cycle.depth + tool.cornerRadius);
    var measureString = "measResult = EdgeMeasure ";
    measureString += (cycle.approach1 == "positive" ? "YPositive" : "YNegative");
    measureString += " originShift=" + xyzFormat.format(-1 * (y + approach(cycle.approach1) * startPositionOffset));
    measureString += " searchDistance=" + xyzFormat.format(cycle.probeClearance);
    writeBlock(measureString);
    forceXYZ();
    onExpandedLinear(touchPositionX1, y, probingDepth, cycle.feedrate);
    onExpandedLinear(x, y, probingDepth, cycle.feedrate);

    var isXNegative = (cycle.approach1 == "negative");
    var isYNegative = (cycle.approach2 == "negative");

    var orientation = "";
    if (isXNegative) {
      orientation = isYNegative ? "BackRight" : "FrontRight";
    } else {
      orientation = isYNegative ? "BackLeft" : "FrontLeft";
    }

    var measureString = "measResult = CornerMeasure";
    measureString += " " + orientation;
    measureString += " Outside";
    measureString += " xMeasureYOffset=" + xyzFormat.format(cycle.probeClearance);
    measureString += " yMeasureXOffset=" + xyzFormat.format(cycle.probeClearance);
    measureString += " searchDistance=" + xyzFormat.format(cycle.probeClearance);
    measureString += " xMeasureZOffset=" + xyzFormat.format((z - cycle.depth + tool.diameter / 2));
    measureString += " yMeasureZOffset=" + xyzFormat.format((z - cycle.depth + tool.diameter / 2));
    measureString += " forceSafeHeight";
    measureString += " skipZMeasure";
    if (probeWCS) {
      measureString += " originXShift=" + xyzFormat.format(-x);
      measureString += " originYShift=" + xyzFormat.format(-y);
      writeBlock(measureString);
    } else {
      measureString += " None";
      writeBlock(measureString);
      expectedArgs = "expectedXPos=" +  xyzFormat.format(x) +
        " expectedYPos=" + xyzFormat.format(y) +
        " measureDirectionX=" + cycle.approach1 +
        " measureDirectionY=" + cycle.approach2;
      writeBlock(getProbingArguments(cycle, undefined, expectedArgs));
    }
    break;
  case "probing-x-plane-angle":
    forceXYZ();
    onExpandedRapid(x, y, cycle.stock);
    onExpandedLinear(x, y, (z - cycle.depth + tool.cornerRadius), cycle.feedrate);
   
    var measureString = "measResult = EdgeMeasureV2 ";
    measureString += (cycle.approach1 == "positive" ? "XPositive" : "XNegative");
    measureString += " searchDistance=" + xyzFormat.format(cycle.probeClearance);
    measureString += " offsetForRotation=" + xyzFormat.format(cycle.probeSpacing);
    measureString += " setRotationOnly=true";
    if (probeWCS) {
      writeBlock(measureString);
    } else {
      measureString += " None";
      writeBlock(measureString);
      expectedArgs = "expectedXPos=" +  xyzFormat.format(x + approach(cycle.approach1) * startPositionOffset) +
        " measureDirectionX=" + (cycle.approach1 == "positive" ? "positive" : "negative");
      writeBlock(getProbingArguments(cycle, undefined, expectedArgs));
    }
    break;
  case "probing-y-plane-angle":
    forceXYZ();
    onExpandedRapid(x, y, cycle.stock);
    onExpandedLinear(x, y, (z - cycle.depth + tool.cornerRadius), cycle.feedrate);
   
    var measureString = "measResult = EdgeMeasureV2 ";
    measureString += (cycle.approach1 == "positive" ? "YPositive" : "YNegative");
    measureString += " searchDistance=" + xyzFormat.format(cycle.probeClearance);
    measureString += " offsetForRotation=" + xyzFormat.format(cycle.probeSpacing);
    measureString += " setRotationOnly=true";
    if (probeWCS) {
      writeBlock(measureString);
    } else {
      measureString += " None";
      writeBlock(measureString);
      expectedArgs = "expectedYPos=" +  xyzFormat.format(x + approach(cycle.approach1) * startPositionOffset) +
        " measureDirectionY=" + (cycle.approach1 == "positive" ? "positive" : "negative");
      writeBlock(getProbingArguments(cycle, undefined, expectedArgs));
    }
    break;
  default:
    expandCyclePoint(x, y, z);
    return;
  }

  // save probing result in defined wcs
  if (probeWCS && currentSection.workOffset !== undefined) {
    writeBlock("SaveWcs name=\"" + currentSection.workOffset + "\"");
  }
  return;
}

function getProbingArguments(cycle, probeWorkOffsetCode, additionalArguments) {
  var toolToCompensate;
  var tools = getToolTable();
  if (tools.getNumberOfTools()) {
    for (var i = 0; i < tools.getNumberOfTools(); ++i) {
      var tool = tools.getTool(i);
      if (tool.number == cycle.toolWearNumber) {
        toolToCompensate = tool;
      }
    }
  }
  
  return [
    "ProbeGeometry measResult=measResult",
    (cycle.angleAskewAction == "stop-message" ? "angleTolerance=" + xyzFormat.format(cycle.toleranceAngle ? cycle.toleranceAngle : 0) : undefined),
    ((cycle.updateToolWear && cycle.toolWearErrorCorrection < 100) ? "toolWearErrorCorrection=" + xyzFormat.format(cycle.toolWearErrorCorrection ? cycle.toolWearErrorCorrection / 100 : 100) : undefined),
    (cycle.wrongSizeAction == "stop-message" ? "sizeTolerance=" + xyzFormat.format(cycle.toleranceSize ? cycle.toleranceSize : 0) : undefined),
    (cycle.outOfPositionAction == "stop-message" ? "positionTolerance=" + xyzFormat.format(cycle.tolerancePosition ? cycle.tolerancePosition : 0) : undefined),
    (cycle.updateToolWear ? "toolToUpdateWear=\"" + createToolName(toolToCompensate) + "\"" : undefined),
    ((cycle.updateToolWear && cycleType == "probing-z") ? "Length" : undefined),
    ((cycle.updateToolWear && cycleType !== "probing-z") ? "Diameter" : undefined),
    (cycle.updateToolWear ? "toolUpdateTreshold=" + xyzFormat.format(cycle.toolWearUpdateThreshold ? cycle.toolWearUpdateThreshold : 0) : undefined),
    (cycle.printResults ? "printResults" : undefined),
    conditional(probeWorkOffsetCode && probeWCS, "S" + probeWorkOffsetCode),
    additionalArguments
  ];
}

function programIncludesOperationType(operationType) {
  var numberOfSections = getNumberOfSections();
  for (var i = 0; i < numberOfSections; ++i) {
    var section = getSection(i);
    if (operationType == "probe") {
      if (isProbeOperation(section)) {
        return true;
      }
    } else if (operationType == "inspection") {
      if (isInspectionOperation(section)) {
        return true;
      }
    } else {
      error(localize("Unsupported operation type."));
    }
  }
  return false;
}

function writeProbingProgram() {

  addVariable("enumeration toolWearGeometry (Diameter, Length)");
  addVariable("enumeration direction (positive, negative)");

  addModuleReference("import Math");
  addModuleReference("import ToolChangingUtilities");
  addModuleReference("import ToolParameter");
  addModuleReference("import ToolData");

  // TAG add import Math
  probingProgram = [
    "program ProbeGeometry(",
    "  measResult:MeasuringDataWithInfo",
    "  optional expectedDimensionX:number",
    "  optional expectedDimensionY:number",
    "  optional expectedXPos:number",
    "  optional expectedYPos:number",
    "  optional expectedZPos:number  ",
    "  optional measureDirectionX:direction   ",
    "  optional measureDirectionY:direction   ",
    "  optional toolUpdateTreshold:number",
    "  optional toolWearErrorCorrection:number",
    "  optional positionTolerance:number    ",
    "  optional angleTolerance:number",
    "  optional sizeTolerance:number",
    "  optional toolToUpdateWear:string",
    "  optional updateToolWear:toolWearGeometry",
    "  optional printResults:boolean)",
    "",
    "  # Tolerance check",
    "  if sizeTolerance hasvalue ",
    "    outOfDimension:boolean",
    "    if expectedDimensionX hasvalue",
    "        outOfDimension  = Math::Abs(expectedDimensionX - measResult.DimensionX) > sizeTolerance    ",
    "    endif",
    "    if expectedDimensionY hasvalue",
    "        outOfDimension  = Math::Abs(expectedDimensionY - measResult.DimensionY) > sizeTolerance ",
    "    endif",
    "    ",
    "    if outOfDimension",
    "        Dialog message=\"Geometrie out of tolerance\" caption=\"Geometrie out of tolerance\" Error",
    "    endif",
    "  endif",
    "  ",
    "  # Angle check",
    "  if angleTolerance hasvalue",
    "      if measResult.MeasuredTransformation.RotationZ > angleTolerance",
    "         Dialog message=\"Angle out of tolerance\" caption=\"Angle out of tolerance\" Error        ",
    "      endif",
    "  endif",
    "  ",
    "  # Tool wear",
    "  if updateToolWear hasvalue and toolToUpdateWear hasvalue",
    "     if updateToolWear == toolWearGeometry.Diameter",
    "        # get the radius correction from dimension otherwise from position   ",
    "        radiusCorrection:number",
    "        if (expectedDimensionX hasvalue or expectedDimensionY hasvalue)",
    "            if (expectedDimensionX hasvalue and expectedDimensionY hasvalue)",
    "                radiusCorrection = (",
    "                    (expectedDimensionX - measResult.DimensionX) +",
    "                    (expectedDimensionX - measResult.DimensionX)) / 4",
    "            endif",
    "            if (expectedDimensionX hasvalue and not expectedDimensionY hasvalue)",
    "                radiusCorrection = (expectedDimensionX - measResult.DimensionX) / 2",
    "            endif",
    "            if (not expectedDimensionX hasvalue and expectedDimensionY hasvalue)",
    "                radiusCorrection = (expectedDimensionY - measResult.DimensionY) / 2",
    "            endif          ",
    "        else       ",
    "            isXMeasure = expectedXPos hasvalue and measureDirectionX hasvalue",
    "            isYMeasure = expectedYPos hasvalue and measureDirectionY hasvalue            ",
    "            if (isXMeasure or isYMeasure)",
    "                if (isXMeasure and not isYMeasure)",
    "                    radiusCorrection = (expectedXPos - measResult.MeasuredPosition.X) * GetSignFromDirection(measureDirectionX)",
    "                endif",
    "                if (isYMeasure and not isXMeasure)",
    "                    radiusCorrection = (expectedYPos - measResult.MeasuredPosition.Y) * GetSignFromDirection(measureDirectionY)",
    "                endif",
    "                if( isXMeasure and isYMeasure)",
    "                    radiusCorrection = (",
    "                        (expectedXPos - measResult.MeasuredPosition.X) * GetSignFromDirection(measureDirectionX) + ",
    "                        (expectedYPos - measResult.MeasuredPosition.Y) * GetSignFromDirection(measureDirectionY)                        ",
    "                    ) / 2                    ",
    "                endif                        ",
    "            endif        ",
    "        endif",
    "        ",
    // TAG code below needs to get fixed for type we,
    "         toolId = ToolChangingUtilities::GetToolIdFromToolName(toolToUpdateWear)",
    "         newDiameter = ToolParameter::GetToolDiameter(toolNumber=toolId) - radiusCorrection * 2",
    "         ToolData::SetToolGeometry Diameter=newDiameter toolId=toolId",
    "     else",
    "        # length correction",
    "         ",
    "     endif",
    "  endif   ",
    "  ",
    "  # Position",
    "  if positionTolerance hasvalue",
    "    isOutOfTolerance: boolean",
    "    if expectedXPos hasvalue",
    "        isOutOfTolerance = Math::Abs(expectedXPos - measResult.MeasuredPosition.X) > positionTolerance        ",
    "    endif",
    "    if expectedYPos hasvalue",
    "        isOutOfTolerance = Math::Abs(expectedYPos - measResult.MeasuredPosition.Y) > positionTolerance  ",
    "    endif",
    "    if expectedZPos hasvalue",
    "        isOutOfTolerance = Math::Abs(expectedZPos - measResult.MeasuredPosition.Z) > positionTolerance  ",
    "    endif  ",
    "    if isOutOfTolerance",
    "        Dialog message=\"Position out of tolerance\" caption=\"Position out of tolerance\" Error",
    "    endif",
    "  endif  ",
    "endprogram",
    "",
    "function GetSignFromDirection(dir:direction) returns number",
    "    if dir == direction.positive",
    "        return 1",
    "    endif  ",
    "    return -1    ",
    "endfunction"
  ];

  probingProgramOperation = {operationProgram: probingProgram.join(EOL)};
  SimPLProgram.operationList.push(probingProgramOperation);
}

function drilling(cycle) {
  var boreCommandString = new Array();
  var depth = xyzFormat.format(cycle.depth);
  
  boreCommandString.push("Drill");
  boreCommandString.push("depth=" + depth);
  boreCommandString.push("strokeRapidZ=" + xyzFormat.format(cycle.clearance - cycle.retract));
  boreCommandString.push("strokeCuttingZ=" + xyzFormat.format(cycle.retract - cycle.stock));
  writeBlock(boreCommandString.join(" "));
}

function chipBreaking(cycle) {
  var boreCommandString = new Array();
  var depth = xyzFormat.format(cycle.depth);
  
  boreCommandString.push("Drill");
  boreCommandString.push("depth=" + depth);
  boreCommandString.push("strokeRapidZ=" + xyzFormat.format(cycle.clearance - cycle.retract));
  boreCommandString.push("strokeCuttingZ=" + xyzFormat.format(cycle.retract - cycle.stock));
  boreCommandString.push("infeedZ=infeedZ");
  writeBlock(boreCommandString.join(" "));
}

function boreMilling(cycle) {
  if (cycle.numberOfSteps > 2) {
    error("Only 2 steps are allowed for bore-milling.");
  }

  var boreCommandString = new Array();
  var depth = xyzFormat.format(cycle.depth);
  boreCommandString.push("DrillMilling");
  boreCommandString.push("diameter=diameter");
  boreCommandString.push("depth=" + depth);
  boreCommandString.push("infeedZ=infeedZ");
  boreCommandString.push("strokeRapidZ=" + xyzFormat.format(cycle.clearance - cycle.retract));
  boreCommandString.push("strokeCuttingZ=" + xyzFormat.format(cycle.retract - cycle.stock));
  
  if (cycle.numberOfSteps == 2) {
    var xycleaning = cycle.stepover;
    var maxzdepthperstep = tool.fluteLength * 0.8;
    boreCommandString.push("finishingXY=" + xyzFormat.format(xycleaning));
    boreCommandString.push("infeedFinishingZ=" + xyzFormat.format(maxzdepthperstep));
  }
  var bottomcleaning = 0;
  // finishingZ = 1;
  writeBlock(boreCommandString.join(" "));
}

function threadMilling(cycle) {
  var threadString = new Array();
  var depth = xyzFormat.format(cycle.depth);

  threadString.push("SpecialThread");
  // threadString.push('threadName=threadName');
  threadString.push("nominalDiameter=nominalDiameter");
  threadString.push("pitch=pitch");
  threadString.push("depth=" + depth);
  threadString.push("strokeRapidZ=" + xyzFormat.format(cycle.clearance - cycle.retract));
  threadString.push("strokeCuttingZ=" + xyzFormat.format(cycle.retract - cycle.stock));
  if (getProperty("createThreadChamfer")) {
    threadString.push("Deburring");
  }
  // threadString.push("insideOutside=ThreadMillingSide.Inside");
  threadString.push("finishing=finishing");
  if (cycle.threading == "left") {
    threadString.push("direction=ThreadMillingDirection.LeftHandThread");
  } else {
    threadString.push("direction=ThreadMillingDirection.RightHandThread");
  }
  writeBlock(threadString.join(" "));
}

function tapping(cycle) {
  var tappingString = new Array();
  var depth = xyzFormat.format(cycle.depth);
  tappingString.push("ThreadCutting");
  tappingString.push("pitch=" + xyzFormat.format(tool.threadPitch));
  tappingString.push("depth=" + depth);
  tappingString.push("strokeRapidZ=" + xyzFormat.format(cycle.clearance - cycle.retract));
  tappingString.push("strokeCuttingZ=" + xyzFormat.format(cycle.retract - cycle.stock));
  tappingString.push("threadRpm=" + rpmFormat.format(spindleSpeed));
  if (cycleType == "tapping-with-chip-breaking" || cycleType == "left-tapping-with-chip-breaking" || cycleType == "right-tapping-with-chip-breaking") {
    tappingString.push("breakChipInfeed=" + xyzFormat.format(cycle.incrementalDepth));
  }
  if (tool.type == TOOL_TAP_LEFT_HAND) {
    tappingString.push("direction=ThreadMillingDirection.LeftHandThread");
  } else {
    tappingString.push("direction=ThreadMillingDirection.RightHandThread");
  }
  writeBlock(tappingString.join(" "));
}

function formatCycleTime(cycleTime) {
  // cycleTime = cycleTime + 0.5; // round up
  var seconds = cycleTime % 60 | 0;
  var minutes = ((cycleTime - seconds) / 60 | 0) % 60;
  var hours = (cycleTime - minutes * 60 - seconds) / (60 * 60) | 0;
  if (hours > 0) {
    return subst(localize("%1h:%2m:%3s"), hours, minutes, seconds);
  } else if (minutes > 0) {
    return subst(localize("%1m:%2s"), minutes, seconds);
  } else {
    return subst(localize("%1s"), seconds);
  }
}

function dump(name, _arguments) {
  var result = getCurrentRecordId() + ": " + name + "(";
  for (var i = 0; i < _arguments.length; ++i) {
    if (i > 0) {
      result += ", ";
    }
    if (typeof _arguments[i] == "string") {
      result += "'" + _arguments[i] + "'";
    } else {
      result += _arguments[i];
    }
  }
  result += ")";
  writeln(result);
}

function onSectionEnd() {
  if (typeof inspectionProcessSectionEnd == "function") {
    inspectionProcessSectionEnd();
  }
  writeBlock("ToolCompensation Off");
  writeBlock("PathCorrection Off");
  if (getProperty("useZAxisOffset")) {
    writeBlock("ZAxisOffset = 0");
  }
  if (currentSection.isMultiAxis() && (getProperty("rotaryAxisSetup") != "NONE") && getProperty("useRtcp")) {
    writeBlock("Rtcp Off");
  }

  if (getProperty("useSuction")) {
    writeBlock("Suction Off");
  }

  if (getProperty("useSequences") && !isProbeOperation(currentSection) && !isInspectionOperation(currentSection)) {
    if (!getProperty("useExternalSequencesFiles")) {
      resetWriteRedirection();
    }
    spacingDepth += 1;
  }

  writeBlock("EndBlock");

  spacingDepth -= 1;

  writeBlock("endprogram " + "# " + getOperationName(currentSection));
  resetWriteRedirection();
  SimPLProgram.operationList.push(currentOperation);
  forceAny();
}

function writeBuffer(buffer) {
  if (buffer.length > 0) {
    writeBlock(buffer.join(EOL) + EOL);
    writeBlock("");
  }
}

// after all the oiperation calls are set close the main program with all the calls
function finishMainProgram() {
  // write the main program footer
  setWriteRedirection(SimPLProgram.mainProgram);
  spacingDepth += 1;

  // write all subprogram calls in the main Program
  for (var i = 0; i < SimPLProgram.operationList.length; ++i) {
    writeBlock(SimPLProgram.operationList[i].operationCall);
  }

  if (getProperty("writeCoolantCommands")) {
    writeBlock("SpraySystem Off");
  }
    
  if (getProperty("rotaryAxisSetup") != "NONE" && getProperty("useRtcp")) {
    writeBlock("MultiAxisMode Off");
    writeBlock("Rtcp Off");
  }

  setWorkPlane(new Vector(0, 0, 0)); // reset working plane
  if (getProperty("useParkPosition")) {
    writeBlock("Spindle Off");
    writeBlock("MoveToParkPosition");
  } else {
    writeBlock("MoveToSafetyPosition");
    zOutput.reset();
  }

  spacingDepth -= 1;
  writeBlock("endprogram #" + (programName ? (SP + formatComment(programName)) : "") + ((unit == MM) ? " MM" : " INCH"));
  resetWriteRedirection();
}

// add a varibale to the global declarations
function addVariable(value) {
  if (SimPLProgram.globalVariableList.indexOf(value) == -1) {
    SimPLProgram.globalVariableList.push(value);
  }
}
// add a varibale to the global declarations
function addModuleReference(value) {
  if (SimPLProgram.usingList.indexOf(value) == -1) {
    SimPLProgram.usingList.push(value);
  }
}

function onClose() {

  if (getProperty("waitAfterOperation")) {
    writeWaitProgram();
  }
  spacingDepth = 0;

  // check for additional subprograms
  if (programIncludesOperationType("inspection") && typeof writeInspectionProgram == "function") {
    writeInspectionProgram();
  }

  if (programIncludesOperationType("probe")) {
    writeProbingProgram();
  }

  writeBlock(SimPLProgram.moduleName);
  writeBlock("");
  writeBuffer(SimPLProgram.toolDescriptionList);
  writeBlock(SimPLProgram.workpieceGeometry);
  writeBlock("");
  writeBuffer(SimPLProgram.sequenceList);
  writeBuffer(SimPLProgram.usingList);
  writeBuffer(SimPLProgram.externalUsermodules);
  writeBuffer(SimPLProgram.globalVariableList);
  
  finishMainProgram();
  writeBlock(SimPLProgram.mainProgram);
  writeBlock("");

  for (var i = 0; i < SimPLProgram.operationList.length; ++i) {
    writeBlock(SimPLProgram.operationList[i].operationProgram);
  }

  writeBlock("end");

  if (getProperty("useSequences") && !getProperty("useExternalSequencesFiles")) {
    writeComment(spacing);
    writeBlock(sequenceBuffer.toString());
  }
}

function setProperty(property, value) {
  properties[property].current = value;
}
// <<<<< INCLUDED FROM ../../datron next.cps

capabilities = CAPABILITY_MILLING | CAPABILITY_INSPECTION;
description = "DATRON next Inspect Surface";
minimumRevision = 45702;
longDescription = "Generic post for Datron next with Inspect Surface capabilities.";

// code for inspection support
properties.singleResultsFile = {
  title: "Create Single Results File",
  description: "Set to false if you want to store the measurement results for each inspection toolpath in a seperate file",
  group: 0,
  type: "boolean",
  value: true,
  scope: "post"
};
properties.toolOffsetType = {
  title: "Tool offset type",
  description: "Select the which offsets are available on the tool offset page",
  group: 0,
  type: "enum",
  values: [
    {id: "geomWear", title: "Geometry & Wear"},
    {id: "geomOnly", title: "Geometry only"}
  ],
  value: "geomOnly",
  scope: "post"
};
properties.stopOnInspectionEnd = {
  title: "Stop on Inspection End",
  description: "Set to ON to output M0 at the end of each inspection toolpath",
  group: 0,
  type: "boolean",
  value: true,
  scope: "post"
};

var ijkInspectionFormat = createFormat({decimals:5, forceDecimal:true});
// inspection variables
var inspectionVariables = {
  localVariablePrefix: "#",
  probeRadius: 0,
  pointNumber: 1,
  inspectionSections: 0,
  inspectionSectionCount: 0,
  workpieceOffset: "",
};

var macroFormat = createFormat({prefix:inspectionVariables.localVariablePrefix, decimals:0});
function inspectionProcessSectionStart() {
  // only write header once if user selects a single results file
  if (inspectionVariables.inspectionSectionCount == 0 || !getProperty("singleResultsFile") || (currentSection.workOffset != inspectionVariables.workpieceOffset)) {
    inspectionCreateResultsFileHeader();
  }
  inspectionVariables.inspectionSectionCount += 1;
  // write the toolpath name as a comment
  writeBlock("FileWriteLine filename=InspectionFilename value=\";TOOLPATH " + getParameter("operation-comment") + "\"");
  inspectionWriteWorkplaneTransform();
  if (getProperty("toolOffsetType") == "geomOnly") {
    writeComment("Geometry Only");
    // TAG fill
  } else {
    writeComment("Geometry and Wear");
    // TAG fill
  }
}

function inspectionCreateResultsFileHeader() {
  // add the filename to the global variables declarations
  addVariable("InspectionFilename:string");

  writeBlock("InspectionFilename = \"" + getInspectionFilename() + "\"");
  writeComment("delete existing old file");
  writeBlock("if FileExists filename=InspectionFilename");
  writeBlock("  FileDelete filename=InspectionFilename");
  writeBlock("endif");

  writeBlock("");
  if (inspectionVariables.inspectionSectionCount == 0 || !getProperty("singleResultsFile")) {
    writeBlock("FileWriteLine filename=InspectionFilename value=\"START\"");
    if (hasGlobalParameter("document-id")) {
      writeBlock("FileWriteLine filename=InspectionFilename value=\"DOCUMENTID " + getGlobalParameter("document-id") + "\"");
    }
    if (hasGlobalParameter("model-version")) {
      writeBlock("FileWriteLine filename=InspectionFilename value=\"MODELVERSION " + getGlobalParameter("model-version") + "\"");
    }
  }
  // write the toolpath id in the results file
  writeBlock("FileWriteLine filename=InspectionFilename value=\"TOOLPATHID " + getParameter("autodeskcam:operation-id") + "\"");
  inspectionWriteCADTransform();
  inspectionVariables.workpieceOffset = currentSection.workOffset;
}

function inspectionWriteCADTransform() {
  var cadOrigin = currentSection.getModelOrigin();
  var cadWorkPlane = currentSection.getModelPlane().getTransposed();
  var cadEuler = cadWorkPlane.getEuler2(EULER_XYZ_S);
  writeBlock(
    "FileWriteLine filename=InspectionFilename value=\"G331" +
    " N" + inspectionVariables.pointNumber +
    " A" + abcFormat.format(cadEuler.x) +
    " B" + abcFormat.format(cadEuler.y) +
    " C" + abcFormat.format(cadEuler.z) +
    " X" + xyzFormat.format(-cadOrigin.x) +
    " Y" + xyzFormat.format(-cadOrigin.y) +
    " Z" + xyzFormat.format(-cadOrigin.z) +
    "\""
  );
}

function inspectionWriteWorkplaneTransform() {
  var euler = currentSection.workPlane.getEuler2(EULER_XYZ_S);
  var abc = new Vector(euler.x, euler.y, euler.z);
  writeBlock("FileWriteLine filename=InspectionFilename value=\"G330" +
    " N" + inspectionVariables.pointNumber +
    " A" + abcFormat.format(abc.x) +
    " B" + abcFormat.format(abc.y) +
    " C" + abcFormat.format(abc.z) +
    " X0 Y0 Z0 I0 R0\""
  );
}

function inspectionProcessSectionEnd() {
  if (isInspectionOperation(currentSection)) {
    // close inspection results file if the NC has inspection toolpaths
    if ((!getProperty("singleResultsFile")) || (inspectionVariables.inspectionSectionCount == inspectionVariables.inspectionSections)) {
      // TAG add commisioning mode
    }
    writeBlock("FileWriteLine filename=InspectionFilename value=\"END\"");
    writeBlock(getProperty("stopOnInspectionEnd") == true ? "Dialog message=\"Finish Inspection\" Yes No caption=\"Inspection\" Info" : "");
  }
}

function onProbe(status) {
  if (status) {// probe ON
    writeBlock("PrepareXyzSensor"); // command for switching the probe on
  } else { // probe OFF
    writeBlock("UnprepareXyzSensor"); // command for switching the probe off
  }
}

function inspectionCycleInspect(cycle, epx, epy, epz) {
  if (getNumberOfCyclePoints() != 3) {
    error(localize("Missing Endpoint in Inspection Cycle, check Approach and Retract heights"));
  }
  
  if (!isLastCyclePoint()) {
    return;
  }

  forceFeed(); // ensure feed is always output - just in case.
  if (currentSection.isMultiAxis()) {
    error(localize("Multi axis inspect surface is not supported."));
    return;
  }

  var m = getRotation();
  var v = new Vector(cycle.nominalX, cycle.nominalY, cycle.nominalZ);
  var targetPoint = m.multiply(v);
  var pathVector = new Vector(cycle.nominalI, cycle.nominalJ, cycle.nominalK);
  var measureDirection = m.multiply(pathVector).normalized.getNegated();
  var searchDistance = cycle.probeClearance;
  
  // call inspection subprogram
  writeBlock("MeasurePoint(");
  spacingDepth += 1;
  writeBlock("pointID=" + cycle.pointID);
  writeBlock("surfacePos=" + vectorToDatronPosString(targetPoint));
  writeBlock("measureDirection=" + vectorToDatronPosString(measureDirection));
  writeBlock("searchDistance=" + xyzFormat.format(searchDistance));
  writeBlock("surfaceOffset=" + xyzFormat.format(getParameter("operation:inspectSurfaceOffset")));
  writeBlock("upper=" + xyzFormat.format(getParameter("operation:inspectUpperTolerance")));
  writeBlock("lower=" + xyzFormat.format(getParameter("operation:inspectLowerTolerance")) + ")");
  spacingDepth -= 1;
  writeBlock("");
  zOutput.reset();
}

// convert the hsm vector to the datron simpl position initilizer.
function vectorToDatronPosString(vec) {
  return "NewPos(" + xyzFormat.format(vec.x) + ", " + xyzFormat.format(vec.y) + ", " + xyzFormat.format(vec.z) + ")";
}

// adds the necessary references for inspection to the program header
function addInspectionReferences() {
  if (hasProgramInspectionOperations()) {
    SimPLProgram.usingList.push("using File, LinearAlgebra, LinearAlgebraHelper, MeasuringCyclesExecutor, XyzSensor, String");
    SimPLProgram.usingList.push("import AxisSystem");
  }
}

function hasProgramInspectionOperations() {
  var numberOfSections = getNumberOfSections();
  for (var i = 0; i < numberOfSections; ++i) {
    var section = getSection(i);
    if (isInspectionOperation(section)) {
      return true;
    }
  }
  return false;
}

// create the subprogram that makes the inspection probing and the output to the result file.
function writeInspectionProgram() {
  // not triggered is captured by the NEXT Control
  var inspectProgram = [
    "program MeasurePoint pointID:number surfacePos:Position measureDirection:Position searchDistance:number surfaceOffset:number upper:number lower:number",
    "",
    "  # measure",
    "  measureResult = GetMeasuringResultCompensation(",
    "    ArrangeMeasuring(",
    "    targetPosition=surfacePos",
    "    direction=measureDirection",
    "    distance=searchDistance),",
    "  AxisSystem::GetRcsMatrix)",
    "",
    "  # Trigger not found",
    "  if measureResult.active == false",
    "    Dialog message=\"Target Point not found\" caption=\"Inspection error\" Error",
    "  endif",
    "",

    " # write nominal values",
    "  measureNominalString = \"G800 N\" + ValueToString(pointID) + \" X\" + ValueToString(surfacePos.X)  + \" Y\" + ValueToString(surfacePos.Y) + \" Z\" + ValueToString(surfacePos.Z) + \" I\" + ValueToString(measureDirection.X * -1) + \" J\"+ ValueToString(measureDirection.Y * -1) + \" K\" + ValueToString(measureDirection.Z * -1) + \" O\" + ValueToString(surfaceOffset) + \" U\" + ValueToString(upper) + \" L\" + ValueToString(lower)",
    "  measureNominalString = StringReplace(measureNominalString, \",\", \".\")",
    "  FileWriteLine filename=InspectionFilename value=measureNominalString",
    "",

    "  # write result values",
    "   measureResultString = StringFormat(",
    "   baseString=\"G801 N{0} X{1:f3} Y{2:f3} Z{3:f3} R{4:f3}\"",
    "   p0=pointID",
    "   p1=(measureResult.measuredPoint.X + ((measureDirection.X*(-1))*GetProbeTipRadius))",
    "   p2=(measureResult.measuredPoint.Y + ((measureDirection.Y*(-1))*GetProbeTipRadius))",
    "   p3=(measureResult.measuredPoint.Z + ((measureDirection.Z*(-1))*GetProbeTipRadius))",
    "   p4=GetProbeTipRadius)",
    "  measureResultString = StringReplace(measureResultString, \",\", \".\")",
    "",

    "FileWriteLine filename=InspectionFilename value=measureResultString",
    "",
    "  # check result",
    "  measuredPosition = NewPos(",
    "    measureResult.measuredPoint.X,",
    "    measureResult.measuredPoint.Y,",
    "    measureResult.measuredPoint.Z)",
    "",
    "  measuredDifferenceVector = SubPosition(surfacePos, measuredPosition)",
    "  deltaDirection = Normalize(measuredDifferenceVector)",
    "  distance = GetPositionDistance(measuredDifferenceVector)",
    "",
    "  # check deviation direction",
    "  if(GetPositionDistance(SubPosition(Normalize(measuredDifferenceVector),measureDirection))>1)",
    "    distance = distance * -1",
    "  endif",
    "",
    "  if(distance > lower and distance < upper)",
    "    return",
    "  endif",
    "",
    "  # Position out of tolerance",
    "  Dialog message=\"Position out of tolerance\" caption=\"Position out of tolerance\" Error",
    "",
    "endprogram"
  ];

  inspectProgramOperation = {operationProgram: inspectProgram.join(EOL)};
  SimPLProgram.operationList.push(inspectProgramOperation);
}

function getInspectionFilename() {
  var resFile;
  if (getProperty("singleResultsFile")) {
    resFile = getParameter("job-description") + " RESULTS";
  } else {
    resFile = getParameter("operation-comment") + " RESULTS";
  }
  
  resFile = resFile.replace(/[^a-zA-Z0-9_ ]/g, "");
  resFile += ".txt";
  return resFile;
}
