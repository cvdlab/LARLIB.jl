# Julia porting of PLaSM's operators INSR, Q, and Cartesian Product of complexes
# ==============================================================================

using ViewerGL; GL = ViewerGL
using LinearAlgebraicRepresentation
Lar = LinearAlgebraicRepresentation


#	one-dimensional complex generated by Lar implementation of PLaSM's Q
model1D = Lar.qn(5)([.1,-.1,.1,-.1]);
GL.VIEW([ GL.GLFrame2, GL.GLGrid( model1D...,GL.COLORS[1],1 ) ]);

#	two-dimensional complex generated by Cartesian product of Lar models
model2D = Lar.larModelProduct([ model1D, model1D ]);
GL.VIEW([ GL.GLFrame2, GL.GLGrid( model2D...,GL.COLORS[1],1 ) ]);

#	three-dimensional complex generated by FL operator INSR (n-args -> 2-args)
model3D = Lar.INSR(Lar.larModelProduct)([model1D, model1D, model1D]);
GL.VIEW([ GL.GLFrame, GL.GLPol( model3D...,GL.COLORS[1],1 ) ]);
