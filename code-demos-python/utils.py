import streamlit as st 

def _page_width_(width):
    max_width_str = f"max-width: {width}px;"
    st.markdown(
        f"""
    <style>
    .reportview-container .main .block-container{{
        {max_width_str}
    }}
    </style>    
    """,
        unsafe_allow_html=True,
    )

float_formatter = "{:.4f}".format