# Pastry

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `project3` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:project3, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/project3](https://hexdocs.pm/project3).
# Introduction
Pastry is a scalable, distributed object location and routing substrate for wide-area peer-to-peer applications. Pastry performs application-level routing and object location in a potentially very large overlay network of nodes connected via the Internet. It can be used to support a variety of peer-to-peer applications, including global data storage, data sharing, group communication and naming.

# Working
In the project, I implemented the pastry overlay network and an application API that routes keys (messages) to nodes that are closest to it. 
I implement each node in the pastry network as a separate process with its own routing table and neighbour list. The neighbour list contains the list of all live nodes in the network and this is maintained as a list of lists. The routing table is dynamically created each time the node is referenced, from its neighbour list by randomly selecting one candidate from each inner list. Each candidate corresponds to a NodeID that has a incremental number of bits differing from the current NodeID.
I maintain a central map of all NodeIDs which prevent duplicate nodes from being created and also help with failure detection as recorded below.
The application API is implemented as follows. A key is generated and sent as a request from a node using the 'Route' functionality. This function matches the key to a candidate node in the routing table that is closest to it in terms of prefix length. I implement this using a longest prefix matching scheme where the prefix of the key is matched to the prefix of the current node and only the candidates whose prefix is longer than the match is considered for routing. Once a key reaches a node and the candidate list is empty, I stop the process and deliver the key (message) to the current node as it is the closest in the network. 
The program ends when all nodes have completed the assigned set of requests. 
I use a B value of 2 and our NodeID/Key is a 128-bit space string. 

# Failure handling
In my implementation, each node is a separate genserver process and every process is monitored using the supervisor. The supervisor is a process monitoring system that handles every process launched under it. I establish a one to one scheme whereby any failing processes are immediately restarted and so the margin for failure is extremely low. 
Further, my implementation uses a central map and this map is referenced each time any NodeId or neighbour list is created. If any dead nodes exist, it is unavailable in the map and hence is not considered during creation. This prevents the dead nodes from being selected as candidates during the routing process and failure is prevented. 

# Performance measures
The following tests were performed and results were observed :-


  100 Nodes - 10 requests - 2.989 hops on average
  200 Nodes - 10 requests - 3.4935 hops on average
  300 Nodes - 10 requests - 3.7743 hops on average
  500 Nodes - 10 requests - 4.1728 hops on average
  100 Nodes - 50 requests - 2.9358 hops on average

The biggest network I managed to deal with contained 500 Nodes and 10 requests from each Node.






