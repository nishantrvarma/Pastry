defmodule PROJECT3 do
  def main(args) do
    pid = self()          # gets main process pid
    :global.register_name(:final,pid) #registers main process pid as global
    args |> startNode
    receive do
      {:stop} ->
          IO.puts "done"
    end
  end

  


  def receiver(numb, sum, req, numNodes) do
    receive do
      {:ok, "hello", hopcount} ->
        numb = numb-1
        sum = sum + hopcount
        
        if numb==0 do
           
          Process.sleep(100) 
          req = req * numNodes
          avg = sum/req
          IO.puts avg
          final = :global.whereis_name(:final)    #finds main process pid
          send final, {:stop}                     #sends message to main process when numb = 0
          Process.sleep(1000)           
        end
      receiver(numb, sum, req, numNodes)
    end
  end



  def startNode(args) do
    {:ok, _} = Supervisora.start_link
    networkFormation(args)
  end

  def networkFormation(args) do
    numNodes = String.to_integer(Enum.at(args, 0))
    numReq = String.to_integer(Enum.at(args, 1))
    mapset = MapSet.new
    # creating mapset containing all nodeids
    mapset = createNodeIds(numNodes, mapset) 
    list = MapSet.to_list(mapset)
    tuple = List.to_tuple(list)
    # creating actors based on above nodeids
    createActors(numNodes, tuple)
    begin(tuple, numReq, numNodes, 0)
    totNum = numReq * numNodes
    receiver_pid = spawn(PROJECT3, :receiver,[totNum, 0, numReq, numNodes])  # starts receiver process
    :global.register_name(:final_2,receiver_pid)          #sets global name for receiver process
  
  end

  def begin(tuple, numReq, numNodes, i) do
    unless i==numNodes do
      tupleElem = elem(tuple, i)
      route(tupleElem, numReq, tuple)
      begin(tuple, numReq, numNodes, i+1)
    end
  end


  def route(tupleElem, numReq, tuple) do
    if numReq>0 do
      name = String.to_atom(tupleElem)
      key = generateNodeID(128, "")
      GenServer.cast(name, {:node, key, 0})
      route(tupleElem, numReq-1, tuple)
    end
  end

  def generateNeighbor(tuple, i, prefixLen, globalList) do
    if prefixLen<128 do
      t = tuple
      nodeName = elem(t, i)
      prefix = String.slice(nodeName, 0, prefixLen-1)
      prefixLastDigit = String.slice(nodeName, prefixLen-1, 1)
      if prefixLastDigit == "0" do
        prefixLastDigit = "1"
      else
        prefixLastDigit = "0"
      end
      prefix = prefix <> prefixLastDigit
      tempList = traverseTuple(nodeName, tuple, prefix, [], 0)
      globalList = List.insert_at(globalList, prefixLen-1, tempList)
      globalList = generateNeighbor(tuple, i, prefixLen+1, globalList)
    end
    globalList
  end

  def traverseTuple(nodeName, tuple, prefix, lList, j) do
    # removing self addition as neighbor
    if j < tuple_size(tuple) do
      if String.starts_with?(elem(tuple, j), prefix) do
        unless nodeName == elem(tuple, j) do
          list = [elem(tuple, j)]
          lList = lList ++ list
        end
      end
      lList = traverseTuple(nodeName, tuple, prefix, lList, j+1)
    end
    lList
  end

  def createNodeIds(numNodes, mapset) do
    if numNodes>0 do
      nodeID = checkIfExists(mapset)
      mapset = MapSet.put(mapset, nodeID)
      # if node ID is in list create node ID again
      # add this node ID to map or tuple
      mapset = createNodeIds(numNodes-1, mapset)
    end
    mapset
  end

  def createActors(numNodes, tuple) do
    if numNodes>0 do
      nodeName = elem(tuple, numNodes-1)
      nodeid = String.to_atom(nodeName)
      routingList = [[]]
      neighborList = generateNeighbor(tuple, numNodes-1, 1, routingList)
      Supervisora.add_actors(nodeid, neighborList, nodeName)
      createActors(numNodes-1, tuple)
    end
  end

  def generateNodeID(num, nid) do
    if num>0 do
      a = Integer.to_string(Enum.random(0..1))
      nid = nid <> a
      nid = generateNodeID(num-1, nid)
    end
    nid
  end

  def checkIfExists(mapset) do
    id = generateNodeID(128, "")
    if MapSet.member?(mapset, id) do
      id = checkIfExists(mapset)
    end
    id
  end
end