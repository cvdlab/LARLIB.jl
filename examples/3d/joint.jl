
using ViewerGL; GL = ViewerGL
using LinearAlgebraicRepresentation
Lar = LinearAlgebraicRepresentation


#	1D complex in 2D generated by Lar and PLaSM operators
circle = Lar.circle()()
GL.VIEW([ GL.GLFrame2, GL.GLGrid( circle...,GL.COLORS[1],1 ) ]);

intervals = Lar.qn(1)([1.5,1.5])
GL.VIEW([ GL.GLFrame2, GL.GLGrid( intervals...,GL.COLORS[1],1 ) ]);

#	2D complex in 3D generated by Lar and PLaSM operators
cylinders = Lar.larModelProduct([ circle, intervals ])
GL.VIEW([ GL.GLFrame2, GL.GLGrid( cylinders...,GL.COLORS[1],1 ) ]);



function cylinder(r,h,n,k)
	circle = Lar.circle(r)([n])
	interval = Lar.qn(k)([h])
	V,FV = Lar.larModelProduct([ circle, interval ])
	push!(FV, [k for k=1:2*n if k%2==0])
	push!(FV, [k for k=1:2*n if k%2==1])
	
	circle1 = circle[1],[[k] for k=1:size(circle[1],2)]
	interval0 = interval[1], [[k] for k=1:size(interval[1],2)]
	_,EV0 = Lar.larModelProduct([ circle, interval0 ])
	_,EV1 = Lar.larModelProduct([ circle1, interval ])
	EV = append!(EV0,EV1)
	return V,FV,EV
end

rod = Lar.apply(Lar.t(0,0,-1.5), cylinder(1,3,12,1))
triple = Lar.Struct([ rod, Lar.r(pi/2,0,0), rod, Lar.r(0,pi/2,0), rod ])
V,(_,EV,FV,_) = Lar.apply( Lar.s(2.5,2.5,2.5)*Lar.t(-.50,-.5,-.5), Lar.cuboidGrid([1,1,1],true) )
cube = V,FV,EV
#W, EW, FW = catmullclark(V, EV, FV, 2)
#sphere = Lar.apply( Lar.s( 1.4, 1.4, 1.4), (W,FW,EW) )
#object = Lar.Struct([ triple, cube, sphere ])
#V,FV,EV = Lar.struct2lar(object)

GL.VIEW([ GL.GLFrame, GL.GLLines(V,EV) ]);

cop_EV = Lar.coboundary_0(EV::Lar.Cells);
cop_EW = convert(Lar.ChainOp, cop_EV);
cop_FE = Lar.coboundary_1(V, FV::Lar.Cells, EV::Lar.Cells);
W = convert(Lar.Points, V');

V, copEV, copFE, copCF = Lar.space_arrangement( W, cop_EW, cop_FE)


