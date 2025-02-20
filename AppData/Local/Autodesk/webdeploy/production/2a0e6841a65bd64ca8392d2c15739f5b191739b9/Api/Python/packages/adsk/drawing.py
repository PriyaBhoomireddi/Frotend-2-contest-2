# This file was automatically generated by SWIG (http://www.swig.org).
# Version 4.0.2
#
# Do not make changes to this file unless you know what you are doing--modify
# the SWIG interface file instead.

from sys import version_info as _swig_python_version_info
if _swig_python_version_info < (2, 7, 0):
    raise RuntimeError("Python 2.7 or later required")

# Import the low-level C/C++ module
if __package__ or "." in __name__:
    from . import _drawing
else:
    import _drawing

try:
    import builtins as __builtin__
except ImportError:
    import __builtin__

def _swig_repr(self):
    try:
        strthis = "proxy of " + self.this.__repr__()
    except __builtin__.Exception:
        strthis = ""
    return "<%s.%s; %s >" % (self.__class__.__module__, self.__class__.__name__, strthis,)


def _swig_setattr_nondynamic_instance_variable(set):
    def set_instance_attr(self, name, value):
        if name == "thisown":
            self.this.own(value)
        elif name == "this":
            set(self, name, value)
        elif hasattr(self, name) and isinstance(getattr(type(self), name), property):
            set(self, name, value)
        else:
            raise AttributeError("You cannot add instance attributes to %s" % self)
    return set_instance_attr


def _swig_setattr_nondynamic_class_variable(set):
    def set_class_attr(cls, name, value):
        if hasattr(cls, name) and not isinstance(getattr(cls, name), property):
            set(cls, name, value)
        else:
            raise AttributeError("You cannot add class attributes to %s" % cls)
    return set_class_attr


def _swig_add_metaclass(metaclass):
    """Class decorator for adding a metaclass to a SWIG wrapped class - a slimmed down version of six.add_metaclass"""
    def wrapper(cls):
        return metaclass(cls.__name__, cls.__bases__, cls.__dict__.copy())
    return wrapper


class _SwigNonDynamicMeta(type):
    """Meta class to enforce nondynamic attributes (no new attributes) for a class"""
    __setattr__ = _swig_setattr_nondynamic_class_variable(type.__setattr__)


import weakref

class SwigPyIterator(object):
    thisown = property(lambda x: x.this.own(), lambda x, v: x.this.own(v), doc="The membership flag")

    def __init__(self, *args, **kwargs):
        raise AttributeError("No constructor defined - class is abstract")
    __repr__ = _swig_repr
    __swig_destroy__ = _drawing.delete_SwigPyIterator

    def value(self) -> "PyObject *":
        return _drawing.SwigPyIterator_value(self)

    def incr(self, n: "size_t"=1) -> "swig::SwigPyIterator *":
        return _drawing.SwigPyIterator_incr(self, n)

    def decr(self, n: "size_t"=1) -> "swig::SwigPyIterator *":
        return _drawing.SwigPyIterator_decr(self, n)

    def distance(self, x: "SwigPyIterator") -> "ptrdiff_t":
        return _drawing.SwigPyIterator_distance(self, x)

    def equal(self, x: "SwigPyIterator") -> "bool":
        return _drawing.SwigPyIterator_equal(self, x)

    def copy(self) -> "swig::SwigPyIterator *":
        return _drawing.SwigPyIterator_copy(self)

    def next(self) -> "PyObject *":
        return _drawing.SwigPyIterator_next(self)

    def __next__(self) -> "PyObject *":
        return _drawing.SwigPyIterator___next__(self)

    def previous(self) -> "PyObject *":
        return _drawing.SwigPyIterator_previous(self)

    def advance(self, n: "ptrdiff_t") -> "swig::SwigPyIterator *":
        return _drawing.SwigPyIterator_advance(self, n)

    def __eq__(self, x: "SwigPyIterator") -> "bool":
        return _drawing.SwigPyIterator___eq__(self, x)

    def __ne__(self, x: "SwigPyIterator") -> "bool":
        return _drawing.SwigPyIterator___ne__(self, x)

    def __iadd__(self, n: "ptrdiff_t") -> "swig::SwigPyIterator &":
        return _drawing.SwigPyIterator___iadd__(self, n)

    def __isub__(self, n: "ptrdiff_t") -> "swig::SwigPyIterator &":
        return _drawing.SwigPyIterator___isub__(self, n)

    def __add__(self, n: "ptrdiff_t") -> "swig::SwigPyIterator *":
        return _drawing.SwigPyIterator___add__(self, n)

    def __sub__(self, *args) -> "ptrdiff_t":
        return _drawing.SwigPyIterator___sub__(self, *args)
    def __iter__(self):
        return self

# Register SwigPyIterator in _drawing:
_drawing.SwigPyIterator_swigregister(SwigPyIterator)

class Base(object):
    thisown = property(lambda x: x.this.own(), lambda x, v: x.this.own(v), doc="The membership flag")

    def __init__(self, *args, **kwargs):
        raise AttributeError("No constructor defined")
    __repr__ = _swig_repr

    def __deref__(self) -> "adsk::core::Base *":
        return _drawing.Base___deref__(self)

    def __eq__(self, rhs: "Application") -> "bool":

        if not isinstance(self, type(rhs)) :
           return False


        return _drawing.Base___eq__(self, rhs)


    def __ne__(self, rhs: "Base") -> "bool":

        if not isinstance(self, type(rhs)):
           return True


        return _drawing.Base___ne__(self, rhs)


    @staticmethod
    def classType() -> "char const *":
        return _drawing.Base_classType()
    __swig_destroy__ = _drawing.delete_Base

    def _get_objectType(self) -> "char const *":
        return _drawing.Base__get_objectType(self)

    def _get_isValid(self) -> "bool":
        return _drawing.Base__get_isValid(self)

# Register Base in _drawing:
_drawing.Base_swigregister(Base)

def Base_classType() -> "char const *":
    return _drawing.Base_classType()


Base.objectType = property(Base._get_objectType, doc="Returns a string indicating the type of the object.")
Base.isValid = property(Base._get_isValid, doc="Indicates if this object is still valid, i.e. hasn't been deleted or some other action done to invalidate the reference.")

import adsk.core
class PDFSheetsExport(object):
    thisown = property(lambda x: x.this.own(), lambda x, v: x.this.own(v), doc="The membership flag")
    __repr__ = _swig_repr
    AllPDFSheetsExport = _drawing.PDFSheetsExport_AllPDFSheetsExport
    SelectedPDFSheetsExport = _drawing.PDFSheetsExport_SelectedPDFSheetsExport
    CurrentPDFSheetExport = _drawing.PDFSheetsExport_CurrentPDFSheetExport
    RangePDFSheetsExport = _drawing.PDFSheetsExport_RangePDFSheetsExport

    def __init__(self):
        _drawing.PDFSheetsExport_swiginit(self, _drawing.new_PDFSheetsExport())
    __swig_destroy__ = _drawing.delete_PDFSheetsExport

# Register PDFSheetsExport in _drawing:
_drawing.PDFSheetsExport_swigregister(PDFSheetsExport)

class Drawing(adsk.core.Product):
    r"""Object that represents the drawing specific data within a drawing document."""

    thisown = property(lambda x: x.this.own(), lambda x, v: x.this.own(v), doc="The membership flag")

    def __init__(self, *args, **kwargs):
        raise AttributeError("No constructor defined")
    __repr__ = _swig_repr

    def __deref__(self) -> "adsk::drawing::Drawing *":
        return _drawing.Drawing___deref__(self)

    def __eq__(self, rhs: "Drawing") -> "bool":

        if not isinstance(self, type(rhs)) :
           return False


        return _drawing.Drawing___eq__(self, rhs)


    def __ne__(self, rhs: "Drawing") -> "bool":

        if not isinstance(self, type(rhs)):
           return True


        return _drawing.Drawing___ne__(self, rhs)


    @staticmethod
    def classType() -> "char const *":
        return _drawing.Drawing_classType()
    __swig_destroy__ = _drawing.delete_Drawing

    def _get_exportManager(self) -> "adsk::core::Ptr< adsk::drawing::DrawingExportManager >":
        r"""
        Returns the DrawingExportManager for this drawing. You use the ExportManager
        to export the drawing in various formats.
        """
        return _drawing.Drawing__get_exportManager(self)

    def _get_parentDocument(self) -> "adsk::core::Ptr< adsk::core::Document >":
        r"""Returns the parent Document object."""
        return _drawing.Drawing__get_parentDocument(self)

    def _get_unitsManager(self) -> "adsk::core::Ptr< adsk::core::UnitsManager >":
        r"""Returns the UnitsManager object associated with this product."""
        return _drawing.Drawing__get_unitsManager(self)

    def _get_workspaces(self) -> "adsk::core::Ptr< adsk::core::WorkspaceList >":
        r"""Returns the workspaces associated with this product."""
        return _drawing.Drawing__get_workspaces(self)

    def _get_productType(self) -> "std::string":
        r"""
        Returns the product type name of this product. A list of all of
        the possible product types can be obtained by using the 
        Application.supportedProductTypes property.
        """
        return _drawing.Drawing__get_productType(self)

    def findAttributes(self, groupName: "std::string const &", attributeName: "std::string const &") -> "std::vector< adsk::core::Ptr< adsk::core::Attribute >,std::allocator< adsk::core::Ptr< adsk::core::Attribute > > >":
        r"""
        Find attributes attached to objects in this product that match the group and or attribute name.
        This does not find attributes attached directly to the Product or Document objects but finds the
        attributes attached to entities within the product.
        The search string for both the groupName and attributeName arguments can be either an absolute 
        name value, or a regular expression. With an absolute name, the search string must match the
        entire groupName or attributeName, including case. An empty string will match everything.
        For example if you have an attribute group named 'MyStuff' that contains the attribute 'Length1', 
        using the search string 'MyStuff' as the group name and 'Length1' as the attribute name will 
        find the attributes with those names. Searching for 'MyStuff' as the group name and '' as the
        attribute name will find all attributes that have 'MyStuff' as the group name.
        Regular expressions provide a more flexible way of searching. To use a regular expression, 
        prefix the input string for the groupName or attributeName arguments with 're:'. The regular
        expression much match the entire group or attribute name. For example if you have a group that
        contains attributes named 'Length1', 'Length2', 'Width1', and 'Width2' and want to find any 
        of the length attributes you can use a regular expression using the string 're:Length.*'. For more
        information on attributes see the Attributes topic in the user manual. 
        groupName : The search string for the group name. See above for more details. 
        attributeName : The search string for the attribute name. See above for more details. 
        An array of Attribute objects that were found. An empty array is returned if no attributes were found.
        """
        return _drawing.Drawing_findAttributes(self, groupName, attributeName)

    def _get_attributes(self) -> "adsk::core::Ptr< adsk::core::Attributes >":
        r"""Returns the collection of attributes associated with this product."""
        return _drawing.Drawing__get_attributes(self)

    def deleteEntities(self, entities: "ObjectCollection") -> "bool":
        r"""
        Deletes the specified set of entities that are associated with this product. 
        entities : An ObjectCollection containing the list of entities to delete. 
        Returns True if any of the entities provided in the list were deleted. If
        entities were specified that can't be deleted or aren't owned by this product,
        they are ignored.
        """
        return _drawing.Drawing_deleteEntities(self, entities)

    def _get_objectType(self) -> "char const *":
        return _drawing.Drawing__get_objectType(self)

    def _get_isValid(self) -> "bool":
        return _drawing.Drawing__get_isValid(self)

# Register Drawing in _drawing:
_drawing.Drawing_swigregister(Drawing)

def Drawing_classType() -> "char const *":
    return _drawing.Drawing_classType()


Drawing.exportManager = property(Drawing._get_exportManager, doc="Returns the DrawingExportManager for this drawing. You use the ExportManager\nto export the drawing in various formats.")


Drawing.cast = lambda arg: arg if isinstance(arg, Drawing) else None

class DrawingDocument(adsk.core.Document):
    r"""Object that represents a Fusion 360 drawing document."""

    thisown = property(lambda x: x.this.own(), lambda x, v: x.this.own(v), doc="The membership flag")

    def __init__(self, *args, **kwargs):
        raise AttributeError("No constructor defined")
    __repr__ = _swig_repr

    def __deref__(self) -> "adsk::drawing::DrawingDocument *":
        return _drawing.DrawingDocument___deref__(self)

    def __eq__(self, rhs: "DrawingDocument") -> "bool":

        if not isinstance(self, type(rhs)) :
           return False


        return _drawing.DrawingDocument___eq__(self, rhs)


    def __ne__(self, rhs: "DrawingDocument") -> "bool":

        if not isinstance(self, type(rhs)):
           return True


        return _drawing.DrawingDocument___ne__(self, rhs)


    @staticmethod
    def classType() -> "char const *":
        return _drawing.DrawingDocument_classType()
    __swig_destroy__ = _drawing.delete_DrawingDocument

    def _get_drawing(self) -> "adsk::core::Ptr< adsk::drawing::Drawing >":
        r"""Returns the Drawing product object associated with this drawing document."""
        return _drawing.DrawingDocument__get_drawing(self)

    def activate(self) -> "bool":
        r"""
        Causes this document to become the active document in the user interface. 
        Returns true if the activation was successful.
        """
        return _drawing.DrawingDocument_activate(self)

    def _get_name(self) -> "std::string":
        r"""Gets and sets the name of the document."""
        return _drawing.DrawingDocument__get_name(self)

    def _set_name(self, value: "std::string const &") -> "bool":
        r"""Gets and sets the name of the document."""
        return _drawing.DrawingDocument__set_name(self, value)

    def close(self, saveChanges: "bool") -> "bool":
        r"""
        Closes this document. 
        saveChanges : This argument defines what the behavior of the close is when the document
        has been modified. If the document hasn't been modified then this argument
        is ignored and the document is closed. If the document has been modified
        and this argument is false then Fusion 360 will close the document and lose
        any changes. If the document has been modified and this argument is true then
        it will prompt the user if they want to save the changes or not, just the same
        as if the user was to interactively close the document. 
        Returns true if closing the document was successful.
        """
        return _drawing.DrawingDocument_close(self, saveChanges)

    def _get_isModified(self) -> "bool":
        r"""Property that indicates if the document has been modified since it was last saved."""
        return _drawing.DrawingDocument__get_isModified(self)

    def _get_isSaved(self) -> "bool":
        r"""
        Property that indicates if this document has been saved or not. The initial save of
        a document requires that the name and location be specified and requires the saveAs method
        to be used. If the document has been saved then the save method can be used to save changes made.
        """
        return _drawing.DrawingDocument__get_isSaved(self)

    def save(self, description: "std::string const &") -> "bool":
        r"""
        Saves a version of the current document. You must use the SaveAs method the first
        time a document is saved. You can determine if a document has been saved by checking
        the value of the isSaved property. 
        description : The version description for this document 
        Returns true if saving the document was successful.
        """
        return _drawing.DrawingDocument_save(self, description)

    def _get_parent(self) -> "adsk::core::Ptr< adsk::core::Application >":
        r"""Returns the parent Application object."""
        return _drawing.DrawingDocument__get_parent(self)

    def saveAs(self, name: "std::string const &", dataFolder: "DataFolder", description: "std::string const &", tag: "std::string const &") -> "bool":
        r"""
        Performs a Save As on this document. This saves the currently open document to the specified
        location and this document becomes the saved document. If this is a new document that has 
        never been saved you must use the SaveAs method in order to specify the location and name. You
        can determine if the document has been saved by checking the value of the isSaved property. 
        name : The name to use for this document. If this is an empty string, Fusion 360 will use the default name
        assigned when the document was created. 
        dataFolder : The data folder to save this document to. 
        description : The description string of the document. This can be an empty string. 
        tag : The tag string of the document. This can be an empty string. 
        Returns true if the save as was successful.
        """
        return _drawing.DrawingDocument_saveAs(self, name, dataFolder, description, tag)

    def _get_products(self) -> "adsk::core::Ptr< adsk::core::Products >":
        r"""Returns the products associated with this document."""
        return _drawing.DrawingDocument__get_products(self)

    def _get_isActive(self) -> "bool":
        r"""Gets if this document is the active document in the user interface."""
        return _drawing.DrawingDocument__get_isActive(self)

    def _get_isVisible(self) -> "bool":
        r"""Gets if a currently open document is open as visible."""
        return _drawing.DrawingDocument__get_isVisible(self)

    def _get_attributes(self) -> "adsk::core::Ptr< adsk::core::Attributes >":
        r"""Returns the collection of attributes associated with this document."""
        return _drawing.DrawingDocument__get_attributes(self)

    def _get_dataFile(self) -> "adsk::core::Ptr< adsk::core::DataFile >":
        r"""Gets the DataFile that represents this document in A360."""
        return _drawing.DrawingDocument__get_dataFile(self)

    def _get_version(self) -> "std::string":
        r"""Returns the Fusion 360 version this document was last saved with."""
        return _drawing.DrawingDocument__get_version(self)

    def _get_documentReferences(self) -> "adsk::core::Ptr< adsk::core::DocumentReferences >":
        r"""
        Returns a collection containing the documents directly referenced
        by this document.
        """
        return _drawing.DrawingDocument__get_documentReferences(self)

    def _get_isUpToDate(self) -> "bool":
        r"""
        Indicates if any references in the assembly are out of date. This is the API 
        equivalent to the 'Out of Date' notification displayed in the Quick Access Toolbar.
        """
        return _drawing.DrawingDocument__get_isUpToDate(self)

    def _get_allDocumentReferences(self) -> "adsk::core::Ptr< adsk::core::DocumentReferences >":
        r"""
        Returns a collection containing all of the documents referenced directly
        by this document and those referenced by all sub-assemblies.
        """
        return _drawing.DrawingDocument__get_allDocumentReferences(self)

    def _get_objectType(self) -> "char const *":
        return _drawing.DrawingDocument__get_objectType(self)

    def _get_isValid(self) -> "bool":
        return _drawing.DrawingDocument__get_isValid(self)

# Register DrawingDocument in _drawing:
_drawing.DrawingDocument_swigregister(DrawingDocument)

def DrawingDocument_classType() -> "char const *":
    return _drawing.DrawingDocument_classType()


DrawingDocument.drawing = property(DrawingDocument._get_drawing, doc="Returns the Drawing product object associated with this drawing document.")


DrawingDocument.cast = lambda arg: arg if isinstance(arg, DrawingDocument) else None

class DrawingExportManager(Base):
    r"""Provides support to export the drawing in various formats."""

    thisown = property(lambda x: x.this.own(), lambda x, v: x.this.own(v), doc="The membership flag")

    def __init__(self, *args, **kwargs):
        raise AttributeError("No constructor defined")
    __repr__ = _swig_repr

    def __deref__(self) -> "adsk::drawing::DrawingExportManager *":
        return _drawing.DrawingExportManager___deref__(self)

    def __eq__(self, rhs: "DrawingExportManager") -> "bool":

        if not isinstance(self, type(rhs)) :
           return False


        return _drawing.DrawingExportManager___eq__(self, rhs)


    def __ne__(self, rhs: "DrawingExportManager") -> "bool":

        if not isinstance(self, type(rhs)):
           return True


        return _drawing.DrawingExportManager___ne__(self, rhs)


    @staticmethod
    def classType() -> "char const *":
        return _drawing.DrawingExportManager_classType()
    __swig_destroy__ = _drawing.delete_DrawingExportManager

    def createPDFExportOptions(self, filename: "std::string const &") -> "adsk::core::Ptr< adsk::drawing::PDFExportOptions >":
        r"""
        Defines the various settings for a STEP export. 
        filename : The name of the file to export to. Use settings on the returned PDFExportOptions
        object to change other settings. 
        Returns a PDFExportOptions object if successful and null if it should fail.
        """
        return _drawing.DrawingExportManager_createPDFExportOptions(self, filename)

    def execute(self, exportOptions: "DrawingExportOptions") -> "bool":
        r"""
        Executes the export operation to create the file in the format specified by the input ExportOptions object. 
        exportOptions : A DrawingExportOptions object that is created using one of the create methods on the DrawingExportManager object.
        This defines the type of export and defines the options supported for that file type. 
        Returns true if the export was successful.
        """
        return _drawing.DrawingExportManager_execute(self, exportOptions)

    def _get_objectType(self) -> "char const *":
        return _drawing.DrawingExportManager__get_objectType(self)

    def _get_isValid(self) -> "bool":
        return _drawing.DrawingExportManager__get_isValid(self)

# Register DrawingExportManager in _drawing:
_drawing.DrawingExportManager_swigregister(DrawingExportManager)

def DrawingExportManager_classType() -> "char const *":
    return _drawing.DrawingExportManager_classType()


DrawingExportManager.cast = lambda arg: arg if isinstance(arg, DrawingExportManager) else None

class DrawingExportOptions(Base):
    r"""
    The base class for the different drawing export types. This class is never directly used
    in an export because you need the specific export type to specify the type of
    export to be performed.
    """

    thisown = property(lambda x: x.this.own(), lambda x, v: x.this.own(v), doc="The membership flag")

    def __init__(self, *args, **kwargs):
        raise AttributeError("No constructor defined")
    __repr__ = _swig_repr

    def __deref__(self) -> "adsk::drawing::DrawingExportOptions *":
        return _drawing.DrawingExportOptions___deref__(self)

    def __eq__(self, rhs: "DrawingExportOptions") -> "bool":

        if not isinstance(self, type(rhs)) :
           return False


        return _drawing.DrawingExportOptions___eq__(self, rhs)


    def __ne__(self, rhs: "DrawingExportOptions") -> "bool":

        if not isinstance(self, type(rhs)):
           return True


        return _drawing.DrawingExportOptions___ne__(self, rhs)


    @staticmethod
    def classType() -> "char const *":
        return _drawing.DrawingExportOptions_classType()
    __swig_destroy__ = _drawing.delete_DrawingExportOptions

    def _get_filename(self) -> "std::string":
        r"""Gets and sets the filename that the exported file will be written to."""
        return _drawing.DrawingExportOptions__get_filename(self)

    def _set_filename(self, value: "std::string const &") -> "bool":
        r"""Gets and sets the filename that the exported file will be written to."""
        return _drawing.DrawingExportOptions__set_filename(self, value)

    def _get_objectType(self) -> "char const *":
        return _drawing.DrawingExportOptions__get_objectType(self)

    def _get_isValid(self) -> "bool":
        return _drawing.DrawingExportOptions__get_isValid(self)

# Register DrawingExportOptions in _drawing:
_drawing.DrawingExportOptions_swigregister(DrawingExportOptions)

def DrawingExportOptions_classType() -> "char const *":
    return _drawing.DrawingExportOptions_classType()


DrawingExportOptions.filename = property(DrawingExportOptions._get_filename, DrawingExportOptions._set_filename, doc="Gets and sets the filename that the exported file will be written to.")


DrawingExportOptions.cast = lambda arg: arg if isinstance(arg, DrawingExportOptions) else None

class PDFExportOptions(DrawingExportOptions):
    r"""Defines the inputs needed to export the drawing as PDF."""

    thisown = property(lambda x: x.this.own(), lambda x, v: x.this.own(v), doc="The membership flag")

    def __init__(self, *args, **kwargs):
        raise AttributeError("No constructor defined")
    __repr__ = _swig_repr

    def __deref__(self) -> "adsk::drawing::PDFExportOptions *":
        return _drawing.PDFExportOptions___deref__(self)

    def __eq__(self, rhs: "PDFExportOptions") -> "bool":

        if not isinstance(self, type(rhs)) :
           return False


        return _drawing.PDFExportOptions___eq__(self, rhs)


    def __ne__(self, rhs: "PDFExportOptions") -> "bool":

        if not isinstance(self, type(rhs)):
           return True


        return _drawing.PDFExportOptions___ne__(self, rhs)


    @staticmethod
    def classType() -> "char const *":
        return _drawing.PDFExportOptions_classType()
    __swig_destroy__ = _drawing.delete_PDFExportOptions

    def _get_sheetsToExport(self) -> "adsk::drawing::PDFSheetsExport":
        r"""
        Defines which sheets to export. Defaults to AllPDFSheets which
        will create a single PDF file containing all sheets in the drawing.
        the SelectedPDFSheets and CurrentPDFSheet options are dependent on 
        the current selections in the user interface.
        To set this to RangePDFSheets, use the sheetRange property to define
        the range of sheets to print.
        """
        return _drawing.PDFExportOptions__get_sheetsToExport(self)

    def _set_sheetsToExport(self, value: "PDFSheetsExport") -> "bool":
        r"""
        Defines which sheets to export. Defaults to AllPDFSheets which
        will create a single PDF file containing all sheets in the drawing.
        the SelectedPDFSheets and CurrentPDFSheet options are dependent on 
        the current selections in the user interface.
        To set this to RangePDFSheets, use the sheetRange property to define
        the range of sheets to print.
        """
        return _drawing.PDFExportOptions__set_sheetsToExport(self, value)

    def _get_sheetRange(self) -> "std::string":
        r"""
        Defines the range of sheets to export. This can be a string like
        '1-3' or '1-2,5' where you can define a range of sheets and also
        specific sheets. Setting this property will automatically set
        the sheetsToExport setting to SelectedPDFSheets.
        """
        return _drawing.PDFExportOptions__get_sheetRange(self)

    def _set_sheetRange(self, value: "std::string const &") -> "bool":
        r"""
        Defines the range of sheets to export. This can be a string like
        '1-3' or '1-2,5' where you can define a range of sheets and also
        specific sheets. Setting this property will automatically set
        the sheetsToExport setting to SelectedPDFSheets.
        """
        return _drawing.PDFExportOptions__set_sheetRange(self, value)

    def _get_openPDF(self) -> "bool":
        r"""Specifies that the PDF file will be opened after export."""
        return _drawing.PDFExportOptions__get_openPDF(self)

    def _set_openPDF(self, value: "bool") -> "bool":
        r"""Specifies that the PDF file will be opened after export."""
        return _drawing.PDFExportOptions__set_openPDF(self, value)

    def _get_useLineWeights(self) -> "bool":
        r"""Specifies if line weights should be used in the exported PDF file."""
        return _drawing.PDFExportOptions__get_useLineWeights(self)

    def _set_useLineWeights(self, value: "bool") -> "bool":
        r"""Specifies if line weights should be used in the exported PDF file."""
        return _drawing.PDFExportOptions__set_useLineWeights(self, value)

    def _get_filename(self) -> "std::string":
        r"""Gets and sets the filename that the exported file will be written to."""
        return _drawing.PDFExportOptions__get_filename(self)

    def _set_filename(self, value: "std::string const &") -> "bool":
        r"""Gets and sets the filename that the exported file will be written to."""
        return _drawing.PDFExportOptions__set_filename(self, value)

    def _get_objectType(self) -> "char const *":
        return _drawing.PDFExportOptions__get_objectType(self)

    def _get_isValid(self) -> "bool":
        return _drawing.PDFExportOptions__get_isValid(self)

# Register PDFExportOptions in _drawing:
_drawing.PDFExportOptions_swigregister(PDFExportOptions)

def PDFExportOptions_classType() -> "char const *":
    return _drawing.PDFExportOptions_classType()


PDFExportOptions.sheetsToExport = property(PDFExportOptions._get_sheetsToExport, PDFExportOptions._set_sheetsToExport, doc="Defines which sheets to export. Defaults to AllPDFSheets which\nwill create a single PDF file containing all sheets in the drawing.\nthe SelectedPDFSheets and CurrentPDFSheet options are dependent on\nthe current selections in the user interface.\nTo set this to RangePDFSheets, use the sheetRange property to define\nthe range of sheets to print.")


PDFExportOptions.sheetRange = property(PDFExportOptions._get_sheetRange, PDFExportOptions._set_sheetRange, doc="Defines the range of sheets to export. This can be a string like\n'1-3' or '1-2,5' where you can define a range of sheets and also\nspecific sheets. Setting this property will automatically set\nthe sheetsToExport setting to SelectedPDFSheets.")


PDFExportOptions.openPDF = property(PDFExportOptions._get_openPDF, PDFExportOptions._set_openPDF, doc="Specifies that the PDF file will be opened after export.")


PDFExportOptions.useLineWeights = property(PDFExportOptions._get_useLineWeights, PDFExportOptions._set_useLineWeights, doc="Specifies if line weights should be used in the exported PDF file.")


PDFExportOptions.cast = lambda arg: arg if isinstance(arg, PDFExportOptions) else None



