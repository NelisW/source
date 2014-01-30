# cython: language_level=3

#Copyright (c) 2014, Dr Alex Meakins, Raysect Project
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
#     1. Redistributions of source code must retain the above copyright notice,
#        this list of conditions and the following disclaimer.
#
#     2. Redistributions in binary form must reproduce the above copyright
#        notice, this list of conditions and the following disclaimer in the
#        documentation and/or other materials provided with the distribution.
#
#     3. Neither the name of the Raysect Project nor the names of its
#        contributors may be used to endorse or promote products derived from
#        this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

cdef class _NodeBase:
    
    def __init__(self):

        self._parent = None
        self.children = []
        self.root = self
        self._transform = AffineMatrix()
        self._root_transform = AffineMatrix()
        self._root_transform_inverse = AffineMatrix()
        
    cpdef AffineMatrix to(self, _NodeBase node):
        
        if self.root == node.root:

            return node._root_transform_inverse.mul(self._root_transform)
        
        else:
                
            raise ValueError("The target node must be in the same scenegraph.")

    def _check_parent(self, _NodeBase parent):
    
        if parent is self:
            
            raise ValueError("A node cannot be parented to itself or one of it's decendants.")
        
        for child in self.children:
            
            child._check_parent(parent)
        
    def _update(self):
        
        if self._parent is None:
            
            if self.root is not self:
            
                # node has need disconnected from a scenegraph, de-register from old root node                
                self.root._deregister(self)
                self.root = self

            # this node is now a root node
            self._root_transform = AffineMatrix()
            self._root_transform_inverse = AffineMatrix()
        
        else:

            # is node connecting to a different scenegraph?
            if self.root is not self._parent.root:
                
                # de-register from old root and register with new root
                self.root._deregister(self)
                self.root = self._parent.root
                self._parent.root._register(self)

            # update root transforms
            self._root_transform = (<_NodeBase> self._parent)._root_transform.mul(self._transform)
            self._root_transform_inverse = self._root_transform.inverse()
            
        # propagate changes to children
        for child in self.children:
            
            child._update()
        
    def _register(self, _NodeBase node):
    
        pass
    
    def _deregister(self, _NodeBase node):
    
        pass        
