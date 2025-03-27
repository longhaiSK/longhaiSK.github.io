import streamlit as st
import numpy as np

st.title("Text and Vector Input App")

text_input = st.text_input("Enter some text:")

vector_input = st.text_input("Enter a vector (comma-separated numbers):")

if st.button("Print Inputs"):
    if text_input:
        st.write("Text Input:", text_input)
    else:
        st.write("Please enter some text.")

    if vector_input:
        try:
            vector = np.array([float(x.strip()) for x in vector_input.split(",")])
            st.write("Vector Input:", vector)
        except ValueError:
            st.write("Invalid vector input. Please enter comma-separated numbers.")

    else:
        st.write("Please enter a vector.")