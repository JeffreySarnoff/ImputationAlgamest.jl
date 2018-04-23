const OneToZero = Base.OneTo(0)

for A in (:Missing, :Nothing)
  @eval begin    
    function locf(::Type{$A}, data::AbstractArray{T,1}) where {T<:IntFloat}
        indices = findall($A, data)
        return if isempty(indicies)
                   data
               else
                   locf($A, data, indicies)
               end
    end

    function locf(::Type{$A}, data::AbstractArray{T,1}, indicies) where {T} 
        # cannot carry forward into data[bgn] 
        if indicies[1] === 1
            indicies = length(indicies) === 1 ? OneToZero : indicies[2:end]
        end
   
        while !isempty(indices)
           prior_indicies = indicies - 1
           data[indices] = data[prior_indicies]
           indices = findall($A, data)
        end
        return data
    end

    function locf(::Type{$A}, data::AbstractArray{T,2}) where {T<:IntFloat}
        axs1, axs2 = axes(data)
        datavec = Vector{T}(undef, axs1.stop)
        for ax in axs2
            datavec[:] = data[axs1, ax]
            isnothing(findfirst($A, datavec)) && continue
            data[axs1, ax] = locf($A, datavec)
        end
        return data
    end

    function locf(::Type{$A}, data::AbstractArray{T,3}) where {T<:IntFloat}
        axs1, axs2, axs3 = axes(data)
        datamatrix = Matrix{T}(undef, axs1.stop, axs2.stop)
        for ax in axs3
            datamatrix[:,:] = data[axs1, axs2, ax]
            data[axs1, axs2, ax] = locf($A, datamatrix)
        end
        return data
    end

    function locf(::Type{$A}, data::AbstractArray{T,4}) where {T<:IntFloat}
        axs1, axs2, axs3, axs4 = axes(data)
        dataarray = Array{T,3}(undef, axs1.stop, axs2.stop, axs3.stop)
        for ax in axs4
            dataarray[:,:,:] = dataarray[axs1, axs2, axs3, ax]
            data[axs1, axs2, axs3, ax] = locf($A, dataarray)
        end
        return data
    end
    
  end
end
