using OrderedCollections

"""
	characteristicMatrix( FV::Cells )::ChainOp

Binary matrix representing by rows the `p`-cells of a cellular complex.
The input parameter must be of `Cells` type. Return a sparse binary matrix,
providing the basis of a ``Chain`` space of given dimension. Notice that the
number of columns is equal to the number of vertices (0-cells).

# Example

```julia
julia> V,(VV,EV,FV,CV) = Lar.cuboid([1.,1.,1.], true);

julia> Matrix(Lar.characteristicMatrix(FV))

julia> Matrix(Lar.characteristicMatrix(CV))

julia> Matrix(Lar.characteristicMatrix(EV))
```
"""
function characteristicMatrix( FV::Cells )::ChainOp
	I,J,V = Int64[],Int64[],Int8[]
	for f=1:length(FV)
		for k in FV[f]
		push!(I,f)
		push!(J,k)
		push!(V,1)
		end
	end
	M_2 = sparse(I,J,V)
	return M_2
end


"""
	boundary_1( EV::Cells )::ChainOp

Computation of sparse signed boundary operator ``C_1 -> C_0``.

# Example
```julia
julia> V,(VV,EV,FV,CV) = Lar.cuboid([1.,1.,1.], true);

julia> EV
12-element Array{Array{Int64,1},1}:
[1, 2]
[3, 4]
...
[2, 6]
[3, 7]
[4, 8]

julia> Lar.boundary_1( EV::Lar.Cells )
8×12 SparseMatrixCSC{Int8,Int64} with 24 stored entries:
[1 ,  1]  =  -1
[2 ,  1]  =  1
[3 ,  2]  =  -1
...       ...
[7 , 11]  =  1
[4 , 12]  =  -1
[8 , 12]  =  1

julia> Matrix(Lar.boundary_1(EV::Lar.Cells))
8×12 Array{Int8,2}:
-1   0   0   0  -1   0   0   0  -1   0   0   0
1   0   0   0   0  -1   0   0   0  -1   0   0
0  -1   0   0   1   0   0   0   0   0  -1   0
0   1   0   0   0   1   0   0   0   0   0  -1
0   0  -1   0   0   0  -1   0   1   0   0   0
0   0   1   0   0   0   0  -1   0   1   0   0
0   0   0  -1   0   0   1   0   0   0   1   0
0   0   0   1   0   0   0   1   0   0   0   1
```
"""
function boundary_1( EV::Cells )::ChainOp
	out = characteristicMatrix(EV)'
	for e = 1:length(EV)
		out[EV[e][1],e] = -1
	end
	return out
end




"""
	coboundary_0(EV::Cells)

Return the `coboundary_0` signed operator `C_0` -> `C_1`.
"""
coboundary_0(EV::Cells) = convert(ChainOp,transpose(boundary_1(EV::Cells)))




"""
	fix_redundancy(target_mat, cscFV,cscEV)

*Fix the coboundary_1 matrix*, generated by sparse matrix product ``FV * EV^t``, for complexes with some *non-convex cells*. This approach can be used when both `EV` and `FV` of the cellular complex are known. It is exact when cells are convex. Maybe non-exact, introducing spurious incidence coefficients (``redundancies``), when adjacent faces share an edge combinatorially, but not geometrically. This happen when an edge is on the boundary of face A, but only its vertices are on the boundary of face B.  TODO: Similar situations may appear when computing algebraically CF as product of known CV and FV, with non-convex cells.

In order to remove such ``redundancies``, the Euler characteristic of 2-sphere is used, where V-E+F=2. Since we have F=2 (inner and outer face), ``V=E`` must hold, and `d=E-V` is the (non-negative) ``defect`` number, called `nfixs` in the code. It equates the number of columns `edges`
whose sum is greater than 2 for the considered row (face). Remember the in a ``d``-complex, *including* the ``outer cell``, all ``(d-1)``-faces must be shared by exactly 2 ``d``-faces. Note that `FV` *must include* the row of outer shell (exterior face).

# Example

```julia
FV = [[1,2,3,4,5,17,16,12],
[1,2,3,4,6,7,8,9,10,11,12,13,14,15],
[4,5,9,11,12,13,14,15,16,17],
[2,3,6,7], [8,9,10,11]]

FE = [[1,2,3,4,9,20,17,5],
[1,6,10,7,3,8,11,12,14,15,19,18,16,5],
[4,9,20,17,16,18,19,15,13,8],
[2,10,6,7], [11,12,13,14]]

EV = [[1,2],[2,3],[3,4],[4,5],[1,12],[2,6],[3,7],[4,9],[5,17],[6,7],[8,9],
[8,10],[9,11],[10,11],[11,15],[12,13],[12,16],[13,14],[14,15],[16,17]]

V = [0   2   5   7  10   2   5   3   7  3  7  0  3  3  7  0  10;
    16  16  16  16  16  13  13  11  11  8  8  5  5  2  2  0   0]

cscFE = Lar.u_coboundary_1( FV::Lar.Cells, EV::Lar.Cells, false);
Matrix(cscFE)
```

Notice that there are two columns (2 and 13) with 3 ones, hence (3-2)+(3-2)=2 defects to fix. The fixed complex can be shown graphically as:

```julia

VV = [[k] for k in 1:size(V,2)];
#Plasm.view( Plasm.numbering(3)((V,[VV, EV, FV])) )
```
"""
function fix_redundancy(target_mat, cscFV,cscEV) # incidence numbers > 2#E
	nfixs = 0
	faces2fix = []
	edges2fix = []
	# target_mat and cscFV (ref_mat) should have same length per row !
	for face = 1:size(target_mat,1)
		nedges = sum(findnz(target_mat[face,:])[2])
		nverts = sum(findnz(cscFV[face,:])[2])
		if nedges != nverts
			nfixs += nedges - nverts
			#println("face $face, nedges=$nedges, nverts=$nverts")
			push!(faces2fix,face)
		end
	end
	for edge = 1:size(target_mat,2)
		nfaces = sum(findnz(target_mat[:,edge])[2])
		if nfaces > 2
			#println("edge $edge, nfaces=$nfaces")
			push!(edges2fix,edge)
		end
	end
	#println("nfixs=$nfixs")
	pairs2fix = []
	for fh in faces2fix		# for each face to fix
		for ek in edges2fix		# for each edge to fix
			if target_mat[fh, ek]==1	# edge to fix \in face to fix
				v1,v2 = findnz(cscEV[ek,:])[1]
				weight(v) = length( intersect(
							findnz(cscEV[:,v])[1], findnz(target_mat[fh,:])[1] ))
				if weight(v1)>2 && weight(v2)>2
					#println("(fh,ek) = $((fh,ek))")
					push!( pairs2fix, (fh,ek) )
				end
			end
		end
	end
	for (fh,ek) in pairs2fix
		target_mat[fh, ek] = 0
	end
	cscFE = dropzeros(target_mat)
	@assert nnz(cscFE) == 2*size(cscFE,2)
	return cscFE
end
function fix_lack(target_mat, cscFV,cscEV) # incidence numbers < 2#E
end



"""
	u_coboundary_1( FV::Cells, EV::Cells, convex=true)::ChainOp

Compute the sparse *unsigned* coboundary_1 operator ``C_1 -> C_2``.
Notice that the output matrix is `m x n`, where `m` is the number of faces, and `n`
is the number of edges.

# Examples

##  Cellular complex with convex-cells, and without outer cell

```julia
julia> V,(VV,EV,FV,CV) = Lar.cuboid([1.,1.,1.], true);

julia> Lar.u_coboundary_1(FV,EV)
6×12 SparseMatrixCSC{Int8,Int64} with 24 stored entries:
[1 ,  1]  =  1
[3 ,  1]  =  1
[1 ,  2]  =  1
[4 ,  2]  =  1
...		...
[4 , 11]  =  1
[5 , 11]  =  1
[4 , 12]  =  1
[6 , 12]  =  1

julia> Matrix(Lar.u_coboundary_1(FV,EV))
6×12 Array{Int8,2}:
1  1  0  0  1  1  0  0  0  0  0  0
0  0  1  1  0  0  1  1  0  0  0  0
1  0  1  0  0  0  0  0  1  1  0  0
0  1  0  1  0  0  0  0  0  0  1  1
0  0  0  0  1  0  1  0  1  0  1  0
0  0  0  0  0  1  0  1  0  1  0  1

julia> unsigned_boundary_2 = Lar.u_coboundary_1(FV,EV)';
```

Compute the *Unsigned* `coboundary_1` operator matrix as product of two
sparse characteristic matrices.

##  Cellular complex with non-convex cells, and with outer cell

```julia
FV = [[1,2,3,4,5,17,16,12], # outer cell
[1,2,3,4,6,7,8,9,10,11,12,13,14,15],
[4,5,9,11,12,13,14,15,16,17],
[2,3,6,7], [8,9,10,11]]

EV = [[1,2],[2,3],[3,4],[4,5],[1,12],[2,6],[3,7],[4,9],[5,17],[6,7],[8,9],
[8,10],[9,11],[10,11],[11,15],[12,13],[12,16],[13,14],[14,15],[16,17]]

out = Lar.u_coboundary_1( FV::Lar.Cells, EV::Lar.Cells, false)

Matrix(out)
```
In case of expected 2-chains with non-convex cells, instance the method with
`convex = false`, in order to fix a possible redundancy of incidence values, induced by computation through multiplication of characteristic matrices. (Look at columns
2 and 13 before, generated by default).
"""
function u_coboundary_1( FV::Cells, EV::Cells, convex=true::Bool)::ChainOp
	cscFV = characteristicMatrix(FV)
	cscEV = characteristicMatrix(EV)
	out = u_coboundary_1( cscFV::ChainOp, cscEV::ChainOp, convex::Bool)
	return out
end
function u_coboundary_1( cscFV::ChainOp, cscEV::ChainOp, convex=true::Bool)::ChainOp
	temp = cscFV * cscEV'
	I,J,Val = Int64[],Int64[],Int8[]
	for j=1:size(temp,2)
		for i=1:size(temp,1)
			if temp[i,j] == 2
				push!(I,i)
				push!(J,j)
				push!(Val,1)
			end
		end
	end
	cscFE = SparseArrays.sparse(I,J,Val)
	if !convex
		cscFE = fix_redundancy(cscFE,cscFV,cscEV)
	end
	return cscFE
end


"""
	coboundary_1( FV::Cells, EV::Cells)::ChainOp

Generate the *unsigned* sparse matrix of the coboundary_1 operator.
For each row, start with the first incidence number positive (i.e. assign the orientation of the first edge to the 1-cycle of the face), then bounce back and forth between vertex columns/rows of EV and FE.

# Example

```
julia> copFE = coboundary_1(FV::Lar.Cells, EV::Lar.Cells)

julia> Matrix(cscFE)
5×20 Array{Int8,2}:
 1  1  1  1  1  0  0  0  1  0  0  0  0  0  0  0  1  0  0  1
 1  0  1  0  1  1  1  1  0  1  1  1  0  1  1  1  0  1  1  0
 0  0  0  1  0  0  0  1  1  0  0  0  1  0  1  1  1  1  1  1
 0  1  0  0  0  1  1  0  0  1  0  0  0  0  0  0  0  0  0  0
 0  0  0  0  0  0  0  0  0  0  1  1  1  1  0  0  0  0  0  0
```
"""
function coboundary_1(FV::Array{Array{Int64,1},1}, EV::Array{Array{Int64,1},1}) # (::Cells, ::Cells)
	copFV = Lar.lar2cop(FV)
	I,J,Val = findnz(Lar.lar2cop(EV))
	copVE = sparse(J,I,Val)
	triples = hcat([[i,j,1]  for (i,j,v)  in zip(findnz(copFV * copVE)...) if v==2]...)
	I,J,Val = triples[1,:], triples[2,:], triples[3,:]
	Val = convert(Array{Int8,1},Val)
	copFE = sparse(I,J,Val)
	return copFE
end

function coboundary_1( V::Lar.Points, FV::Lar.Cells, EV::Lar.Cells, convex=true::Bool, exterior=false::Bool)::Lar.ChainOp
	# generate unsigned operator's sparse matrix
	cscFV = Lar.characteristicMatrix(FV)
	cscEV = Lar.characteristicMatrix(EV)
	##if size(V,1) == 3
		##copFE = u_coboundary_1( FV::Cells, EV::Cells )
	##elseif size(V,1) == 2
		# greedy generation of incidence number signs
		copFE = Lar.coboundary_1( V, cscFV::Lar.ChainOp, cscEV::Lar.ChainOp, convex, exterior)
	##end
	return copFE
end

function coboundary_1( V::Lar.Points, cscFV::Lar.ChainOp, cscEV::Lar.ChainOp, convex=true::Bool, exterior=false::Bool )::Lar.ChainOp

	cscFE = u_coboundary_1( cscFV::ChainOp, cscEV::ChainOp, convex)
	EV = [findnz(cscEV[k,:])[1] for k=1:size(cscEV,1)]
	cscEV = sparse(coboundary_0( EV::Cells ))
	for f=1:size(cscFE,1)
		chain = findnz(cscFE[f,:])[1]	#	dense
		cycle = spzeros(Int8,cscFE.n)	#	sparse

		edge = findnz(cscFE[f,:])[1][1]; sign = 1
		cycle[edge] = sign
		chain = setdiff( chain, edge )
		while chain != []
			boundary = sparse(cycle') * cscEV
			_,vs,vals = findnz(dropzeros(boundary))

			rindex = vals[1]==1 ? vf = vs[1] : vf = vs[2]
			r_boundary = spzeros(Int8,cscEV.n)	#	sparse
			r_boundary[rindex] = 1
			r_coboundary = cscEV * r_boundary
			r_edge = intersect(findnz(r_coboundary)[1],chain)[1]
			r_coboundary = spzeros(Int8,cscEV.m)	#	sparse
			r_coboundary[r_edge] = EV[r_edge][1]<EV[r_edge][2] ? 1 : -1

			lindex = vals[1]==-1 ? vi = vs[1] : vi = vs[2]
			l_boundary = spzeros(Int8,cscEV.n)	#	sparse
			l_boundary[lindex] = -1
			l_coboundary = cscEV * l_boundary
			l_edge = intersect(findnz(l_coboundary)[1],chain)[1]
			l_coboundary = spzeros(Int8,cscEV.m)	#	sparse
			l_coboundary[l_edge] = EV[l_edge][1]<EV[l_edge][2] ? -1 : 1

			if r_coboundary != -l_coboundary  # false iff last edge
				# add edge to cycle from both sides
				rsign = rindex == EV[r_edge][1] ? 1 : -1
				lsign = lindex == EV[l_edge][2] ? -1 : 1
				cycle = cycle + rsign * r_coboundary + lsign * l_coboundary
			else
				# add last (odd) edge to cycle
				rsign = rindex==EV[r_edge][1] ? 1 : -1
				cycle = cycle + rsign * r_coboundary
			end
			chain = setdiff(chain, findnz(cycle)[1])
		end
		for e in findnz(cscFE[f,:])[1]
			cscFE[f,e] = cycle[e]
		end
	end
	if exterior && size(V,1)==2
		# put matrix in form: first row outer cell; with opposite sign )
		V = convert(Array{Float64,2},transpose(V))
		EV = convert(ChainOp, SparseArrays.transpose(boundary_1(EV)))

		outer = Arrangement.get_external_cycle(V::Points, cscEV::ChainOp,
			cscFE::ChainOp)
		copFE = [ -cscFE[outer:outer,:];  cscFE[1:outer-1,:];  cscFE[outer+1:end,:] ]
		# induce coherent orientation of matrix rows (see examples/orient2d.jl)
		for k=1:size(copFE,2)
			spcolumn = findnz(copFE[:,k])
			if sum(spcolumn[2]) != 0
				row = spcolumn[1][2]
				sign = spcolumn[2][2]
				copFE[row,:] = -sign * copFE[row,:]
			end
		end
		return copFE
	else
		return cscFE
	end
end





"""
	u_boundary_2(FV::Cells, EV::Cells)::ChainOp

Return the unsigned `boundary_2` operator `C_2` -> `C_1`.
"""
u_boundary_2(EV, FV) = (u_coboundary_1(FV, EV))'



"""
	u_boundary_3(CV::Cells, FV::Cells)::ChainOp

Return the unsigned `boundary_3` operator `C_3` -> `C_2`.
"""
u_boundary_3(CV, FV) = (u_coboundary_2(CV, FV))'




"""
	u_coboundary_2( CV::Cells, FV::Cells[, convex=true::Bool] )::ChainOp

Unsigned 2-coboundary matrix `∂_2 : C_2 -> C_3` from 2-chain to 3-chain space.
Compute algebraically the *unsigned* coboundary matrix `∂_2` from
characteristic matrices of `CV` and `FV`. Currently usable *only* with complexes of *convex* cells.

#	Examples

## First example

(1) Compute the *boundary matrix* for a block of 3-cells of size ``[32,32,16]``;

(2) compute and show the *boundary* 2-cell array `boundary_2D_cells` by decodifying the (`mod 2`) result of multiplication of  the *boundary_3 matrix* `∂_2'`, transpose of *unsigned  coboundary_2* matrix  times the coordinate vector of the ``total`` 3-chain.

```julia
julia> using SparseArrays, Lar
julia> V,(_,_,FV,CV) = Lar.cuboidGrid([32,32,16], true)
julia> ∂_2 = Lar.u_coboundary_2( CV, FV)
julia> coord_vect_of_all_3D_cells  = ones(size(∂_2,1),1)
julia> coord_vect_of_boundary_2D_cells = ∂_2' * coord_vect_of_all_3D_cells .% 2
julia> out = coord_vect_of_boundary_2D_cells
julia> boundary_2D_cells = [ FV[f] for f in findnz(sparse(out))[1] ]
#julia> hpc = Plasm.lar2exploded_hpc(V, boundary_2D_cells)(1.25,1.25,1.25)
#julia> Plasm.view(hpc)
```
## Second example example

Using the boundary matrix of the `32 x 32 x 16` "image block" (better if stored on disk)
compute the boundary 2-complex of a random sub-image inside the block.

```julia
julia> coord_vect_of_segment = [x>0.25 ? 1 : 0  for x in rand(size(∂_2,1)) ]
julia> out = ∂_2' * coord_vect_of_segment .% 2
julia> boundary_2D_cells = [ FV[f] for f in findnz(sparse(out))[1] ]
#julia> hpc = Plasm.lar2exploded_hpc(V, boundary_2D_cells)(1.1,1.1,1.1)
#julia> Plasm.view(hpc)
```

"""
function u_coboundary_2( CV::Cells, FV::Cells, convex=true::Bool)::ChainOp
	cscCV = characteristicMatrix(CV)
	cscFV = characteristicMatrix(FV)
	temp = cscCV * cscFV'
	I,J,value = Int64[],Int64[],Int8[]
	for j=1:size(temp,2)
		nverts = length(FV[j])
		for i=1:size(temp,1)
			if temp[i,j] == nverts
				push!(I,i)
				push!(J,j)
				push!(value,1)
			end
		end
	end
	cscCF = SparseArrays.sparse(I,J,value)
	if !convex
		@assert "not yet implemented: TODO!"
	end
	return cscCF
end




"""
	chaincomplex( W::Points, EW::Cells )::Tuple{Array{Cells,1},Array{ChainOp,1}}

Chain 2-complex construction from basis of 1-cells.

From the minimal input, construct the whole
two-dimensional chain complex, i.e. the bases for linear spaces C_1 and
C_2 of 1-chains and  2-chains, and the signed coboundary operators from
C_0 to C_1 and from C_1 to C_2.

# Example

```julia
julia> W =
[0.0  0.0  0.0  0.0  1.0  1.0  1.0  1.0  2.0  2.0  2.0  2.0  3.0  3.0  3.0  3.0
0.0  1.0  2.0  3.0  0.0  1.0  2.0  3.0  0.0  1.0  2.0  3.0  0.0  1.0  2.0  3.0]
# output
2×16 Array{Float64,2}: ...

julia> EW =
[[1, 2],[2, 3],[3, 4],[5, 6],[6, 7],[7, 8],[9, 10],[10, 11],[11, 12],[13, 14],
[14, 15],[15, 16],[1, 5],[2, 6],[3, 7],[4, 8],[5, 9],[6, 10],[7, 11],[8, 12],
[9, 13],[10, 14],[11, 15],[12, 16]]
# output
24-element Array{Array{Int64,1},1}: ...

julia> V,bases,coboundaries = chaincomplex(W,EW)

julia> bases[1]	# edges
24-element Array{Array{Int64,1},1}: ...

julia> bases[2] # faces -- previously unknown !!
9-element Array{Array{Int64,1},1}: ...

julia> coboundaries[1] # coboundary_1
24×16 SparseMatrixCSC{Int8,Int64} with 48 stored entries: ...

julia> Matrix(coboundaries[2]) # coboundary_1: faces as oriented 1-cycles of edges
9×24 Array{Int8,2}:
-1  0  0  1  0  0  0  0  0  0  0  0  1 -1  0  0  0  0  0  0  0  0  0  0
0 -1  0  0  1  0  0  0  0  0  0  0  0  1 -1  0  0  0  0  0  0  0  0  0
0  0 -1  0  0  1  0  0  0  0  0  0  0  0  1 -1  0  0  0  0  0  0  0  0
0  0  0 -1  0  0  1  0  0  0  0  0  0  0  0  0  1 -1  0  0  0  0  0  0
0  0  0  0 -1  0  0  1  0  0  0  0  0  0  0  0  0  1 -1  0  0  0  0  0
0  0  0  0  0 -1  0  0  1  0  0  0  0  0  0  0  0  0  1 -1  0  0  0  0
0  0  0  0  0  0  0 -1  0  0  1  0  0  0  0  0  0  0  0  0  0  1 -1  0
0  0  0  0  0  0 -1  0  0  1  0  0  0  0  0  0  0  0  0  0  1 -1  0  0
0  0  0  0  0  0  0  0 -1  0  0  1  0  0  0  0  0  0  0  0  0  0  1 -1
```
"""
function chaincomplex( W, EW )
	V = convert(Array{Float64,2},LinearAlgebra.transpose(W))
	EV = convert(ChainOp, SparseArrays.transpose(boundary_1(EW)))

	V,cscEV,cscFE = planar_arrangement(V,EV)

	ne,nv = size(cscEV)
	nf = size(cscFE,1)
	EV = [findall(!iszero, cscEV[e,:]) for e=1:ne]
	FV = [collect(Set(vcat([EV[e] for e in findall(!iszero, cscFE[f,:])]...)))  for f=1:nf]

	function ord(cells)
		return [sort(cell) for cell in cells]
	end
	temp = copy(convert(ChainOp, LinearAlgebra.transpose(cscEV)))
	for k=1:size(temp,2)
		h = findall(!iszero, temp[:,k])[1]
		temp[h,k] = -1
	end
	cscEV = convert(ChainOp, LinearAlgebra.transpose(temp))
	bases, coboundaries = (ord(EV),ord(FV)), (cscEV,cscFE)
	return V',bases,coboundaries
end

"""
	chaincomplex( W::Points, FW::Cells, EW::Cells )
		::Tuple{ Array{Cells,1}, Array{ChainOp,1} }

Chain 3-complex construction from bases of 2- and 1-cells.

From the minimal input, construct the whole
two-dimensional chain complex, i.e. the bases for linear spaces C_1 and
C_2 of 1-chains and  2-chains, and the signed coboundary operators from
C_0 to C_1  and from C_1 to C_2.

# Example
```julia
julia> L = Lar = LinearAlgebraicRepresentation

julia> cube_1 = ([0 0 0 0 1 1 1 1; 0 0 1 1 0 0 1 1; 0 1 0 1 0 1 0 1],
[[1,2,3,4],[5,6,7,8],[1,2,5,6],[3,4,7,8],[1,3,5,7],[2,4,6,8]],
[[1,2],[3,4],[5,6],[7,8],[1,3],[2,4],[5,7],[6,8],[1,5],[2,6],[3,7],[4,8]] )

julia> cube_2 = L.Struct([L.t(0,0,0.5), L.r(0,0,pi/3), cube_1])

julia> V,FV,EV = L.struct2lar(L.Struct([ cube_1, cube_2 ]))

julia> W,bases,coboundaries = L.chaincomplex(V,FV,EV)

julia> (EV, FV, CV), (cscEV, cscFE, cscCF) = bases,coboundaries

julia> FV # bases[2]
18-element Array{Array{Int64,1},1}:
[1, 3, 4, 6]
[2, 3, 5, 6]
[7, 8, 9, 10]
[1, 2, 3, 7, 8]
[4, 6, 9, 10, 11, 12]
[5, 6, 11, 12]
[1, 4, 7, 9]
[2, 5, 11, 13]
[2, 8, 10, 11, 13]
[2, 3, 14, 15, 16]
[11, 12, 13, 17]
[11, 12, 13, 18, 19, 20]
[2, 3, 13, 17]
[2, 13, 14, 18]
[15, 16, 19, 20]
[3, 6, 12, 15, 19]
[3, 6, 12, 17]s
[14, 16, 18, 20]

julia> CV # bases[3]
3-element Array{Array{Int64,1},1}:
[2, 3, 5, 6, 11, 12, 13, 14, 15, 16, 18, 19, 20]
[2, 3, 5, 6, 11, 12, 13, 17]
[1, 2, 3, 4, 6, 7, 8, 9, 10, 11, 12, 13, 17]

julia> cscEV # coboundaries[1]
34×20 SparseMatrixCSC{Int8,Int64} with 68 stored entries: ...

julia> cscFE # coboundaries[2]
18×34 SparseMatrixCSC{Int8,Int64} with 80 stored entries: ...

julia> cscCF # coboundaries[3]
4×18 SparseMatrixCSC{Int8,Int64} with 36 stored entries: ...
```
"""
function chaincomplex(V,FV,EV)
	W = convert(Points, copy(V)');
    cop_EV = coboundary_0(EV::Lar.Cells);
    cop_FE = coboundary_1(V, FV::Lar.Cells, EV::Lar.Cells);

    W, copEV, copFE, copCF = space_arrangement( W::Lar.Points, cop_EV::Lar.ChainOp, cop_FE::Lar.ChainOp)
	ne,nv = size(copEV)
	nf = size(copFE,1)
	nc = size(copCF,1)
	EV = [findall(!iszero, copEV[e,:]) for e=1:ne]
	FV = [collect(Set(vcat([EV[e] for e in findall(!iszero, copFE[f,:])]...)))  for f=1:nf]
	CV = [collect(Set(vcat([FV[f] for f in findall(!iszero, copCF[c,:])]...)))  for c=2:nc]
	function ord(cells)
		return [sort(cell) for cell in cells]
	end
	temp = copy(convert(ChainOp, LinearAlgebra.transpose(copEV)))
	for k=1:size(temp,2)
		h = findall(!iszero, temp[:,k])[1]
		temp[h,k] = -1
	end
	copEV = convert(ChainOp, LinearAlgebra.transpose(temp))
	bases, coboundaries = (ord(EV),ord(FV),ord(CV)), (copEV,copFE,copCF)
	W = convert(Points, (LinearAlgebra.transpose(V')))
	return W,bases,coboundaries
end


# Collect LAR models in a single LAR model
function collection2model(collection)
	W,FW,EW = collection[1]
	shiftV = size(W,2)
	for k=2:length(collection)
		V,FV,EV = collection[k]
		W = [W V]
		FW = [FW; FV + shiftV]
		EW = [EW; EV + shiftV]
		shiftV = size(W,2)
	end
	return W,FW,EW
end



function arrange2D(V,EV)
	cop_EV = coboundary_0(EV::Cells)
	cop_EW = convert(ChainOp, cop_EV)
	W = convert(Points,V')
	V, copEV, copFE = Arrangement.planar_arrangement(W::Points, cop_EW::ChainOp)
	EVs = FV2EVs(copEV, copFE) # polygonal face fragments
@show copEV
@show copFE
	triangulated_faces = triangulate2D(V, [copEV, copFE])
	FVs = convert(Array{Cells}, triangulated_faces)
	V = convert(Points,V')
	return V,FVs,EVs, copEV, copFE
end


"""
	pols2tria(W::Points, copEV::ChainOp,
			copFE::ChainOp, copCF::ChainOp)

Take a chain 3-complex and return arrays of boundary simplicial complexes.
Input and ouput Points (embedding geometry) are by columns.
Arrays of simplicial complexes are by body, by face, and by boundary of face.
```

```
"""
function pols2tria(W, copEV, copFE, copCF) # W by columns
	V = convert(Points,W')
	triangulated_faces = triangulate(V, [copEV, copFE])
	EVs = FV2EVs(copEV, copFE) # polygonal face fragments
	# triangulated_faces = [ item for (k,item) in enumerate(triangulated_faces)
	# 	if isdefined(triangulated_faces,k) && item ≠ Any[]  ]
	FVs = convert(Array{Cells}, triangulated_faces)
	CVs = []
	for cell in 1:copCF.m
		obj = []
        for f in copCF[cell, :].nzind
            triangles = triangulated_faces[f]
			append!(obj, triangles)
        end
		push!(CVs,obj)
    end
	V = convert(Points,V')
	return V,CVs,FVs,EVs
end
## Fs is the signed coord vector of a subassembly
## the logic is to compute the corresponding reduced coboundary matrices
## and finally call the standard method of the function.
function pols2tria(W, copEV, copFE, copCF, Fs) # W by columns
	# make copies of coboundary operators

	# compute the reduced copCF
	CFtriples = findnz(copCF)
	triples = [triple for triple in zip(CFtriples...)]
	newtriples = [(row,col,val) for (row,col,val) in triples if Fs[col] ≠ 0]
	newF = [k for (k,f) in enumerate(Fs) if Fs[k] ≠ 0]
	fdict = Dict( zip(newF, 1:length(newF)))
	triples = hcat([[row,fdict[col],val] for (row,col,val) in newtriples]...)
	newCF = sparse( triples[1,:], triples[2,:], triples[3,:] )
	copCF = convert( SparseMatrixCSC{Int8,Int64}, newCF )

	# compute the reduced copFE
	FEtriples = findnz(copFE)
	triples = [triple for triple in zip(FEtriples...)]
	newtriples = [(row,col,val) for (row,col,val) in triples if Fs[row] ≠ 0]
	newF = [k for (k,f) in enumerate(Fs) if Fs[k] ≠ 0]
	newcol = collect(Set([col for (row,col,val) in newtriples]))
	facedict = Dict( zip(newF, 1:length(newF)))
	edgedict = Dict( zip(newcol, 1:length(newcol)))
	triples = hcat([ [facedict[row],edgedict[col],val] for (row,col,val) in newtriples]...)
	newFE = sparse( triples[1,:], triples[2,:], triples[3,:] )
	copFE = convert( SparseMatrixCSC{Int8,Int64}, newFE )

	# compute the reduced copEV
	EVtriples = findnz(copEV)
	triples = [triple for triple in zip(EVtriples...)]
	newtriples = [(row,col,val) for (row,col,val) in triples if row in keys(edgedict)]
	# newcol = collect(Set([col for (row,col,val) in newtriples]))
	# vertdict = Dict( zip(newcol, 1:length(newcol)))
	# triples = hcat([[edgedict[row],vertdict[col],val] for (row,col,val) in newtriples]...)
	triples = hcat([[edgedict[row],col,val] for (row,col,val) in newtriples]...)
	newEV = sparse( triples[1,:], triples[2,:], triples[3,:] )
	copEV = convert( SparseMatrixCSC{Int8,Int64}, newEV )

	#W = convert(Points,W') # BOH...!!
	# finally compute the cells, faces, and edges of subassembly
	V,CVs,FVs,EVs = pols2tria(W, copEV, copFE, copCF)
	return V,CVs,FVs,EVs
end


"""
	permutationOrbits(perm::OrderedDict)::Array{Array{Int64,1},1}

Compute the ``cycles`` of a `perm` ``permutation`` of the first integers (starting from 1).

The `perm` parameter is an ``ordered dictionary``. The output is an
array of arrays of integers (``orbits``).

# Examples

```
julia> dict(List) = OrderedDict((i,x) for (i,x) in enumerate(List))
dict (generic function with 1 method)

julia> perm = dict([2, 3, 4, 5, 6, 7, 8, 1]);

julia> permutationOrbits(perm)
1-element Array{Array{Int64,1},1}:
 [2, 3, 4, 5, 6, 7, 8, 1, 2]

julia> perm = dict([3,9,8,12,10,7,2,11,6,4,1,5]);

julia> permutationOrbits(perm)
3-element Array{Array{Int64,1},1}:
 [3, 8, 11, 1, 3]
 [9, 6, 7, 2, 9]
 [12, 5, 10, 4, 12]

julia> permutationOrbits(Dict())
0-element Array{Array{Int64,1},1}

julia> permutationOrbits(Dict(1=>1))
1-element Array{Array{Int64,1},1}:
 [1, 1]
```
"""
function permutationOrbits(perm::OrderedDict)
	out = Array{Int64,1}[]
    while perm ≠ Dict()
        x = collect(keys(perm))[1]
        orbit = Int64[]
        while x in keys(perm)
            append!(orbit, perm[x])
			y,x = x,perm[x]
            delete!(perm,y)
		end
        append!(out, [ push!(orbit,orbit[1]) ]  )
	end
    return out
end


## Generation of oriented boundary faces
"""
	faces2polygons(copEV::ChainOp, copFE::ChainOp)::Array{Array{Array{Int64,1},1},1}

Generate an array of faces (array of polygons, given as oriented cycles of vertex indices).

The input is a chain of two ``chain operators`` (coboundaries).
The output is a list of list of polygons, given as oriented ``cycles of vertex`` indices.
``Outer`` polygons are counterclockwise-oriented; ``inner`` polygons are clockwise-oriented.
The first polygon of each face is the outer one.

#	Example
Both a polygon with ``holes`` and polygons ``fitting the holes`` are defined in the following.
The reader should note the ``mutual orientation`` of holes and polygons fitting them.
They are correctly derived from a sparse `copFE` matrix created by ``TGW algorithm`` in 2D.

```
julia> V = [540.313 540.313 2038.65 2038.65 1990.25 1990.25 583.951 583.951 2038.65 2038.65 1551.97 1990.25 1551.97 1990.25 409.035 2265.24 409.035 2265.24 540.313 540.313 583.951 583.951 934.346 1246.02 934.346 1246.02; -2129.59 -1653.96 -2129.59 -1493.96 -2064.15 -1493.96 -2064.15 -1653.96 -1104.9 -1221.14 -1104.9 -1137.88 -1137.88 -1221.14 -1007.31 -1007.31 -2210.65 -2210.65 -1109.81 -1360.09 -1104.1 -1360.09 -1104.9 -1104.9 -1137.88 -1137.88]

julia> copEV = sparse([1, 2, 1, 8, 2, 3, 3, 7, 4, 5, 4, 7, 5, 6, 6, 8, 9, 10, 9, 13, 10, 14, 11, 12, 11, 14, 12, 13, 15, 16, 15, 17, 16, 18, 17, 18, 19, 21, 19, 22, 20, 21, 20, 22, 23, 24, 23, 26, 24, 25, 25, 26], [1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7, 8, 8, 9, 9, 10, 10, 11, 11, 12, 12, 13, 13, 14, 14, 15, 15, 16, 16, 17, 17, 18, 18, 19, 19, 20, 20, 21, 21, 22, 22, 23, 23, 24, 24, 25, 25, 26, 26], Int8[-1, -1, 1, -1, 1, -1, 1, -1, -1, -1, 1, 1, 1, -1, 1, 1, -1, -1, 1, -1, 1, -1, -1, -1, 1, 1, 1, 1, -1, -1, 1, -1, 1, -1, 1, 1, -1, -1, 1, -1, -1, 1, 1, 1, -1, -1, 1, -1, 1, -1, 1, 1])

julia> copFE = sparse([1, 3, 1, 3, 1, 3, 1, 3, 1, 3, 1, 3, 1, 3, 1, 3, 2, 3, 2, 3, 2, 3, 2, 3, 2, 3, 2, 3, 3, 3, 3, 3, 3, 4, 3, 4, 3, 4, 3, 4, 3, 5, 3, 5, 3, 5, 3, 5], [1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7, 8, 8, 9, 9, 10, 10, 11, 11, 12, 12, 13, 13, 14, 14, 15, 16, 17, 18, 19, 19, 20, 20, 21, 21, 22, 22, 23, 23, 24, 24, 25, 25, 26, 26], Int8[-1, 1, 1, -1, 1, -1, -1, 1, 1, -1, 1, -1, 1, -1, -1, 1, -1, 1, 1, -1, -1, 1, 1, -1, -1, 1, 1, -1, -1, 1, -1, 1, -1, 1, 1, -1, 1, -1, -1, 1, 1, -1, -1, 1, -1, 1, 1, -1])

julia> faces2polygons(copEV,copFE)
5-element Array{Array{Array{Int64,1},1},1}:
 [[1, 3, 4, 6, 5, 7, 8, 2]]
 [[9, 11, 13, 12, 14, 10]]
 [[2, 8, 7, 5, 6, 4, 3, 1], [10, 14, 12, 13, 11, 9], [15, 17, 18, 16], [19, 21, 22, 20], [24, 26, 25, 23]]
 [[20, 22, 21, 19]]
 [[23, 25, 26, 24]]

julia> model = (V, [ [[v] for v=1:size(V,2)], Lar.cop2lar(copEV) ])
([540.313 540.313 … 934.346 1246.02; -2129.59 -1653.96 … -1137.88 -1137.88], Array{Array{Int64,1},1}[[[1], [2], [3], [4], [5], [6], [7], [8], [9], [10]  …  [17], [18], [19], [20], [21], [22], [23], [24], [25], [26]], [[1, 2], [1, 3], [3, 4], [5, 6], [5, 7], [7, 8], [4, 6], [2, 8], [9, 10], [9, 11]  …  [16, 18], [17, 18], [19, 20], [21, 22], [19, 21], [20, 22], [23, 24], [23, 25], [25, 26], [24, 26]]])

julia> GL.VIEW( GL.numbering(200)( model, GL.COLORS[1], 0.1 ) );
```
"""
function faces2polygons(copEV,copFE)
	polygons = Array{Array{Int64,1},1}[]
	cycles = Array{Array{Array{Int64,1},1},1}[]
	for f=1:size(copFE,1)
		edges,signs = findnz(copFE[f,:])
		permutationMap = OrderedDict([ s>0 ? findnz(copEV[e,:])[1] : reverse(findnz(copEV[e,:])[1])
				for (e,s) in zip(edges,signs)])
		orbits = permutationOrbits(permutationMap)
		edgecycles = [[[ orbit[k], orbit[k+1] ] for k=1:length(orbit)-1]  for orbit in orbits]
		push!(polygons, [orbit[1:end-1] for orbit in orbits])
		push!(cycles, edgecycles)
	end
	return polygons,cycles
end
