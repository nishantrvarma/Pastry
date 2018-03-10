defmodule Supervisora do
        use Supervisor 
    
        def start_link do        
            Supervisor.start_link(__MODULE__, [],  name: :supervisorNode)       
        end
    
        def init(_) do
            children = 
            [            
                worker(Actora, []),                   
            ]        
            supervise(children, strategy: :simple_one_for_one)
        end
    
        def add_actors(nodeid, neighborList, nodeName) do
            ar = [nodeid, neighborList, nodeName]
            Supervisor.start_child(:supervisorNode, [ar])     
        end
    end