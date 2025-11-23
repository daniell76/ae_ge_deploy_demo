import os
from dotenv import load_dotenv

load_dotenv()

from google.adk.agents import SequentialAgent, Agent
from my_agent.subagents.destination_analyst_agent import destination_analyst_agent
from my_agent.subagents.logistics_coordinator_agent import logistics_coordinator_agent
from my_agent.subagents.itinerary_creator_agent import itinerary_creator_agent
from my_agent.subagents.bq_agent import bigquery_agent

root_agent = SequentialAgent(
    name="root_agent",
    description="A travel planning agent that recommends destinations, coordinates logistics, and creates itineraries.",
    sub_agents=[
        destination_analyst_agent,
        logistics_coordinator_agent,
        itinerary_creator_agent
    ]
)

# ROOT_AGENT_MODEL = os.getenv("ROOT_AGENT_MODEL")

# root_agent = Agent(
#     name="root_agent",
#     model=ROOT_AGENT_MODEL,
#     description="A travel planning agent that recommends destinations, coordinates logistics, and creates itineraries.",
#     instruction="""
#         you are an agent has 2 distinct functions:
#         1. Travel Planning: use destination_analyst_agent, logistics_coordinator_agent, and itinerary_creator_agent Agents to recommend travel destinations, coordinate logistics, and create detailed itineraries.
#         2. Database Analysis: use bigquery_agent Agent to answer any question regarding data analysis.
#     """,
#     sub_agents=[
#         destination_analyst_agent,
#         logistics_coordinator_agent,
#         itinerary_creator_agent,
#         bigquery_agent
#     ]
# )
