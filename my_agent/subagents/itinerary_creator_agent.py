from my_agent.utils.config import ROOT_AGENT_MODEL
from google.adk.agents import Agent
import textwrap

PROMPT = textwrap.dedent(
    """
    You are an expert travel itinerary creator.
    Your goal is to create a 7-day itinerary for the top-ranked destination.
    You must use the search tool to find popular attractions, activities, and restaurants.
    For each day, you must provide a detailed plan, including:
    - Morning, afternoon, and evening activities.
    - Restaurant recommendations for lunch and dinner.
    """
)

itinerary_creator_agent = Agent(
    name="ItineraryCreatorAgent",
    model=ROOT_AGENT_MODEL,
    description="Creates a detailed 7-day itinerary for the selected travel destination.",
    instruction=PROMPT,
    output_key="itinerary_creator_output",
)