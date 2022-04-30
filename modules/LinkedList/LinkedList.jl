mutable struct LinkedList
    value 
    next

    function LinkedList(value)
        this = new()
        this.value = value
        this.next = nothing

        return this
    end
end

function Base.getproperty(this::LinkedList, s::Symbol)
    if s == :insertar
        function(value)
            aux = this
            while aux.next != nothing
                aux = aux.next
            end
            aux.next = LinkedList(value)
        end
    elseif s == :imprimir
        function()
            aux = this
            print("[")
            while aux.next != nothing
                print("$(aux.value), ")
                aux = aux.next
            end
            print("$(aux.value)]")
                
        end
    else
        getfield(this, s)
    end
end