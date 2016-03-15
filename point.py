import maya.OpenMayaMPx as OpenMayaMPx
import maya.OpenMaya as OpenMaya
import maya.OpenMayaUI as OpenMayaUI
import maya.OpenMayaRender as OpenMayaRender

gl_renderer = OpenMayaRender.MHardwareRenderer.theRenderer()
gl_func_table = gl_renderer.glFunctionTable()

commandName = 'point'

class Point(OpenMayaMPx.MPxLocatorNode):
    kPluginNodeId = OpenMaya.MTypeId(0x90000002)
    
    def __init__(self):
        OpenMayaMPx.MPxLocatorNode.__init__(self)
    
    def draw(self, view, mdag_path, display_style, display_status):
        view.beginGL()
        
        gl_func_table.glBegin(OpenMayaRender.MGL_LINES)
        # top
        gl_func_table.glVertex3f(-1, 1, -1)
        gl_func_table.glVertex3f(1, 1, -1)
        
        gl_func_table.glVertex3f(1, 1, -1)
        gl_func_table.glVertex3f(1, 1, 1)
        
        gl_func_table.glVertex3f(1, 1, 1)
        gl_func_table.glVertex3f(-1, 1, 1)
        
        gl_func_table.glVertex3f(-1, 1, 1)
        gl_func_table.glVertex3f(-1, 1, -1)
        
        # bottom
        gl_func_table.glVertex3f(-1, -1, -1)
        gl_func_table.glVertex3f(1, -1, -1)
        
        gl_func_table.glVertex3f(1, -1, -1)
        gl_func_table.glVertex3f(1, -1, 1)
        
        gl_func_table.glVertex3f(1, -1, 1)
        gl_func_table.glVertex3f(-1, -1, 1)
        
        gl_func_table.glVertex3f(-1, -1, 1)
        gl_func_table.glVertex3f(-1, -1, -1)
        
        # left
        gl_func_table.glVertex3f(-1, -1, -1)
        gl_func_table.glVertex3f(-1, 1, -1)
        
        gl_func_table.glVertex3f(-1, 1, -1)
        gl_func_table.glVertex3f(-1, 1, 1)
        
        gl_func_table.glVertex3f(-1, 1, 1)
        gl_func_table.glVertex3f(-1, -1, 1)
        
        gl_func_table.glVertex3f(-1, -1, 1)
        gl_func_table.glVertex3f(-1, -1, -1)
        
        # right
        gl_func_table.glVertex3f(1, -1, -1)
        gl_func_table.glVertex3f(1, 1, -1)
        
        gl_func_table.glVertex3f(1, 1, -1)
        gl_func_table.glVertex3f(1, 1, 1)
        
        gl_func_table.glVertex3f(1, 1, 1)
        gl_func_table.glVertex3f(1, -1, 1)
        
        gl_func_table.glVertex3f(1, -1, 1)
        gl_func_table.glVertex3f(1, -1, -1)
        gl_func_table.glEnd()
        
        view.endGL()

def nodeCreator():
    return OpenMayaMPx.asMPxPtr( Point() )

def nodeInitializer():
    return True
    #return OpenMaya.MStatus.kSuccess

def initializePlugin(obj):
    plugin = OpenMayaMPx.MFnPlugin(obj, 'Jason Labbe', '1.0', 'Any')
    try:
        print 'Loading point node'
        plugin.registerNode(commandName, 
                            Point.kPluginNodeId, 
                            nodeCreator, 
                            nodeInitializer,
                            OpenMayaMPx.MPxNode.kLocatorNode)
    except:
        raise RuntimeError, 'Failed to register node: {0}'.format(commandName)

def uninitializePlugin(obj):
    plugin = OpenMayaMPx.MFnPlugin(obj)
    try:
        plugin.deregisterNode(Point.kPluginNodeId)
    except:
        raise RuntimeError, 'Failed to register node: {0}'.format(commandName)
