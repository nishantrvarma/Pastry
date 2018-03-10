defmodule Actora do
    use GenServer

    def start_link(arg \\[]) do
        nodeid = Enum.at(arg,0)
        neighborList = Enum.at(arg,1)
        nodeName = Enum.at(arg, 2)
        GenServer.start_link(__MODULE__, [nodeid, neighborList, nodeName], name: nodeid)
    end

    def handle_cast({:node, key, hopcount}, state) do
         
        Process.sleep(100) 
        nodeid = Enum.at(state, 0)
        nodeName =  Enum.at(state,2)
        routeTable = Enum.at(state, 1)
        maxMatchLen = longestPrefixMatchLength(nodeName, key, 0)
        neighborList = []
        unless maxMatchLen == 128 do
            neighborList = Enum.at(routeTable,maxMatchLen)
        end

        if length(neighborList) == 0 do
             
            Process.sleep(100) 
            final_2 = :global.whereis_name(:final_2) #finds pid for receiver process
            send final_2, {:ok,"hello", hopcount}    #sends message to receiver once counter is 10
            IO.puts hopcount   
            Process.sleep(100)          
            
            
        else
            len = length(neighborList)-1
            rand = Enum.random(0..len)
            neighbor = Enum.at(neighborList, rand)
            Process.sleep(100)
            GenServer.cast(String.to_atom(neighbor), {:node, key, hopcount+1})
             
            Process.sleep(100) 
        end
        {:noreply, state}
    end

    def longestPrefixMatchLength(nodeName, key, i) do
        if(String.at(nodeName, i) == String.at(key, i)) do
            i = longestPrefixMatchLength(nodeName, key, i+1)
        end
        i
    end
end