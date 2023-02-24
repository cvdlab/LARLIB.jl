#	cylinders and toroidal surface by Julia's implementation of PLaSM operators

using ViewerGL; GL = ViewerGL
using LinearAlgebraicRepresentation
Lar = LinearAlgebraicRepresentation


#	1D complex in 2D generated by Lar and PLaSM operators
circle = Lar.circle()()
GL.VIEW([ GL.GLFrame2, GL.GLGrid( circle...,GL.COLORS[1],1 ) ]);

#	1D complex in 1D generated by Lar and PLaSM operators
intervals = Lar.qn(5)([2,-.5])
GL.VIEW([ GL.GLFrame2, GL.GLGrid( intervals...,GL.COLORS[1],1 ) ]);

#	2D complex in 3D generated by Lar and PLaSM operators
cylinders = Lar.larModelProduct([ circle, intervals ])
GL.VIEW([ GL.GLFrame2, GL.GLGrid( cylinders...,GL.COLORS[1],1 ) ]);

#	other visualizations
V,FV = cylinders
FW = [[f] for f in FV]
GL.VIEW( push!( GL.GLExplode( V,FW, 1.2,1.2,1.2, 1,0.2 ), GL.GLFrame2) );
GL.VIEW( push!( GL.GLExplode( V,FW, 1.,1.,1., 99,1 ), GL.GLFrame2) );

# see
function schlegel3D(t::Float64,d::Float64)
    function schlegel3D0(V)
        W = Array{Float64,2}(undef,size(V))
        for k=1:size(V,2)
            W[4,k] = V[4,k] + t # translation
            W[1,k] = V[1,k]*d/W[4,k] # projection
            W[2,k] = V[2,k]*d/W[4,k] # projection
            W[3,k] = V[3,k]*d/W[4,k] # projection
        end
        return W[1:3,:]
    end
    return schlegel3D0
end

# 2D complex in 4D generated as topological product of circles
toroidal = Lar.larModelProduct([ Lar.circle(8)(), Lar.circle(2)() ])
V,FV = toroidal

# removal of 4-th coodinate: ortho-projection 4D -> 3D
GL.VIEW([ GL.GLFrame2, GL.GLGrid( V[1:3,:], FV, GL.COLORS[1],0.2 ) ]);

# schlegel projection 4D -> 3D
W = schlegel3D(-6.,2.)(V)
GL.VIEW([ GL.GLFrame2, GL.GLGrid( W, FV, GL.COLORS[1],0.2 ) ]);

# schlegel projection 4D -> 3D rainbow
meshes = []
W,EW = W, FV
for k=1:length(EW)
	color = GL.COLORS[k%12+1] - (rand(Float64,4)*0.1)
	push!(meshes, GL.GLGrid(W,[EW[k]],color,1) )
end
GL.VIEW(meshes);


