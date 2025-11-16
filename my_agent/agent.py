from google.adk.agents import SequentialAgent
from my_agent.subagents.destination_analyst_agent import destination_analyst_agent
from my_agent.subagents.logistics_coordinator_agent import logistics_coordinator_agent
from my_agent.subagents.itinerary_creator_agent import itinerary_creator_agent

root_agent = SequentialAgent(
    name="root_agent",
    description="A travel planning agent that recommends destinations, coordinates logistics, and creates itineraries.",
    sub_agents=[
        destination_analyst_agent,
        logistics_coordinator_agent,
        itinerary_creator_agent
    ]
)
