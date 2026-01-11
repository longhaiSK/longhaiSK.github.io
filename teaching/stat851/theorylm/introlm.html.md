---
title: "Introduction"
format: 
  html: 
    keep-md: true
---

## Multiple Linear Regression 

Suppose we have observations on $Y$ and $X_j$. The data can be represented in matrix form.

$$
\underset{n \times 1}{y} = \underset{n \times p}{X} \beta + \underset{n \times 1}{\epsilon}
$$

where the error terms are distributed as: $$
\epsilon \sim N_n(0, \sigma^2 I_n),
$$

in which $I_n$ is the identity matrix: $$
I_n = \begin{pmatrix} 
1 & 0 & \dots & 0 \\ 
0 & 1 & \dots & 0 \\ 
\vdots & \vdots & \ddots & \vdots \\ 
0 & 0 & \dots & 1 
\end{pmatrix}
$$ The scalar equation for a single observation is: $$
Y_i = \beta_0 + \beta_1 X_{i1} + \dots + \beta_p X_{ip} + \epsilon_i
$$

## Examples 

### Polynomial Regression 

Polynomial regression fits a curved line to the data points but remains linear in the parameters ($\beta$).

The model equation is: $$
y_i = \beta_0 + \beta_1 x_i + \beta_2 x_i^2 + \dots + \beta_{p-1} x_i^{p-1}
$$

### Design Matrix Construction 

The design matrix $X$ is constructed by taking powers of the input variable.

$$
y = \begin{pmatrix} y_1 \\ \vdots \\ y_n \end{pmatrix} = 
\begin{pmatrix} 
1 & x_1 & x_1^2 & \dots & x_1^{p-1} \\ 
1 & x_2 & x_2^2 & \dots & x_2^{p-1} \\ 
\vdots & \vdots & \vdots & \ddots & \vdots \\ 
1 & x_n & x_n^2 & \dots & x_n^{p-1} 
\end{pmatrix} 
\begin{pmatrix} \beta_0 \\ \beta_1 \\ \vdots \\ \beta_{p-1} \end{pmatrix} + 
\begin{pmatrix} \epsilon_1 \\ \epsilon_2 \\ \vdots \\ \epsilon_n \end{pmatrix}
$$

### One-Way ANOVA 

ANOVA can be expressed as a linear model using categorical predictors (dummy variables).

Suppose we have 3 groups ($G_1, G_2, G_3$) with observations: $$
Y_{ij} = \mu_i + \epsilon_{ij}, \quad \epsilon_{ij} \sim N(0, \sigma^2)
$$

$$
\overset{G_1}{
  \boxed{
    \begin{matrix} Y_{11} \\ Y_{12} \end{matrix}
  }
}
\quad
\overset{G_2}{
  \boxed{
    \begin{matrix} Y_{21} \\ Y_{22} \end{matrix}
  }
}
\quad
\overset{G_3}{
  \boxed{
    \begin{matrix} Y_{31} \\ Y_{32} \end{matrix}
  }
}
$$

We construct the matrix $X$ to select the group mean ($\mu$) corresponding to the observation:

$$
\underset{6 \times 1}{y} = \underset{6 \times 3}{X} \begin{pmatrix} \mu_1 \\ \mu_2 \\ \mu_3 \end{pmatrix} + \epsilon
$$

$$
\begin{bmatrix}
Y_{11} \\ Y_{12} \\ Y_{21} \\ Y_{22} \\ Y_{31} \\ Y_{32}
\end{bmatrix} = 
\begin{bmatrix}
1 & 0 & 0 \\
1 & 0 & 0 \\
0 & 1 & 0 \\
0 & 1 & 0 \\
0 & 0 & 1 \\
0 & 0 & 1
\end{bmatrix}
\begin{bmatrix}
\mu_1 \\ \mu_2 \\ \mu_3
\end{bmatrix} + \epsilon
$$

### Analysis of Covariance (ANCOVA) 

ANCOVA combines continuous variables and categorical (dummy) variables in the same design matrix.

$$
\begin{bmatrix}
Y_1 \\ \vdots \\ Y_n
\end{bmatrix} =
\begin{bmatrix}
X_{1,\text{cont}} & 1 & 0 \\
X_{2,\text{cont}} & 1 & 0 \\
\vdots & 0 & 1 \\
X_{n,\text{cont}} & 0 & 1
\end{bmatrix} \beta + \epsilon
$$

## Least Squares Estimation 

For the general linear model $y = X\beta + \epsilon$, the Least Squares estimator is:

$$
\hat{\beta} = (X'X)^{-1}X'y
$$

The predicted values ($\hat{y}$) are obtained via the Projection Matrix (Hat Matrix) $P_X$:

$$
\hat{y} = X\hat{\beta} = X(X'X)^{-1}X'y = P_X y
$$

The residuals and Sum of Squared Errors are:

$$
\hat{e} = y - \hat{y}
$$ $$
\text{SSE} = ||\hat{e}||^2
$$

The coefficient of determination is: $$
R^2 = \frac{\text{SST} - \text{SSE}}{\text{SST}}
$$ where $\text{SST} = \sum (y_i - \bar{y})^2$.

## Geometric Perspective of Least Square Estimation 

We align the coordinate system to the models for clarity:

1.  **Reduced Model (**$M_0$): Represented by the **X-axis** (labeled $j_3$).
    -   $\hat{y}_0$ is the projection of $y$ onto this axis.
2.  **Full Model (**$M_1$): Represented by the **XY-plane** (the floor).
    -   $\hat{y}_1$ is the projection of $y$ onto this plane ($z=0$).
3.  **Observed Data (**$y$): A point in 3D space.

The "improvement" due to adding predictors is the distance between $\hat{y}_0$ and $\hat{y}_1$.




::: {.cell layout-align="center"}
::: {#fig-geometry-simple .cell-output-display}

```{=html}
<div class="plotly html-widget html-fill-item" id="htmlwidget-6f467e0333683dacf84f" style="width:90%;height:576px;"></div>
<script type="application/json" data-for="htmlwidget-6f467e0333683dacf84f">{"x":{"visdat":{"15746509b1074":["function () ","plotlyVisDat"],"1574674555903":["function () ","data"],"15746f470fa0":["function () ","data"],"15746252d936":["function () ","data"],"15746d32696b":["function () ","data"],"1574668a6f691":["function () ","data"],"157462985df44":["function () ","data"],"157461404fea8":["function () ","data"]},"cur_data":"157461404fea8","attrs":{"1574674555903":{"alpha_stroke":1,"sizes":[10,100],"spans":[1,20],"x":{},"y":{},"z":{},"type":"scatter3d","mode":"lines","line":{"color":"gray","width":5},"name":"M₀ Subspace (j₃)","hoverinfo":"none","inherit":true},"1574674555903.1":{"alpha_stroke":1,"sizes":[10,100],"spans":[1,20],"z":[[0,0],[0,0]],"type":"surface","x":[0,8],"y":[0,8],"opacity":0.10000000000000001,"showscale":false,"colorscale":[[0,1],["lightgrey","lightgrey"]],"name":"M₁ Subspace","inherit":true},"15746f470fa0":{"alpha_stroke":1,"sizes":[10,100],"spans":[1,20],"x":{},"y":{},"z":{},"type":"scatter3d","mode":"lines+markers","line":{"color":"blue","width":10},"marker":{"size":5,"color":"blue"},"name":"y (Observed)","inherit":true},"15746252d936":{"alpha_stroke":1,"sizes":[10,100],"spans":[1,20],"x":{},"y":{},"z":{},"type":"scatter3d","mode":"lines+markers","line":{"color":"red","width":10},"marker":{"size":5,"color":"red"},"name":"ŷ₀","inherit":true},"15746d32696b":{"alpha_stroke":1,"sizes":[10,100],"spans":[1,20],"x":{},"y":{},"z":{},"type":"scatter3d","mode":"lines+markers","line":{"color":"darkgreen","width":10},"marker":{"size":5,"color":"darkgreen"},"name":"ŷ₁","inherit":true},"1574668a6f691":{"alpha_stroke":1,"sizes":[10,100],"spans":[1,20],"x":{},"y":{},"z":{},"type":"scatter3d","mode":"lines","line":{"color":"red","width":5,"dash":"solid"},"name":"e₀ (RSS₀)","inherit":true},"157462985df44":{"alpha_stroke":1,"sizes":[10,100],"spans":[1,20],"x":{},"y":{},"z":{},"type":"scatter3d","mode":"lines","line":{"color":"darkgreen","width":5,"dash":"solid"},"name":"e₁ (RSS₁)","inherit":true},"157461404fea8":{"alpha_stroke":1,"sizes":[10,100],"spans":[1,20],"x":{},"y":{},"z":{},"type":"scatter3d","mode":"lines","line":{"color":"orange","width":6,"dash":"dot"},"name":"Diff","inherit":true},"157461404fea8.1":{"alpha_stroke":1,"sizes":[10,100],"spans":[1,20],"type":"scatter3d","mode":"text","x":[4,4,4],"y":[5,0,5],"z":[3,0,0],"text":["y","ŷ₀","ŷ₁"],"textfont":{"size":18,"color":"black","family":"Arial Black"},"textposition":["top center","top center","bottom center"],"showlegend":false,"inherit":true},"157461404fea8.2":{"alpha_stroke":1,"sizes":[10,100],"spans":[1,20],"type":"scatter3d","mode":"text","x":[4,4],"y":[2.5,5],"z":[1.5,1.5],"text":["e₀","e₁"],"textfont":{"size":14,"color":"darkblue"},"textposition":"middle right","showlegend":false,"inherit":true}},"layout":{"margin":{"b":40,"l":60,"t":50,"r":10},"scene":{"xaxis":{"title":"j3 (Intercept)","titlefont":{"size":20}},"yaxis":{"title":"x1 (Predictor)","titlefont":{"size":15}},"zaxis":{"title":"Error","titlefont":{"size":15}},"aspectmode":"data","camera":{"eye":{"x":1.5,"y":1.5,"z":0.5}}},"title":"Geometric Interpretation: Aligned View","hovermode":"closest","showlegend":true},"source":"A","config":{"modeBarButtonsToAdd":["hoverclosest","hovercompare"],"showSendToCloud":false},"data":[{"x":[0,8],"y":[0,0],"z":[0,0],"type":"scatter3d","mode":"lines","line":{"color":"gray","width":5},"name":"M₀ Subspace (j₃)","hoverinfo":["none","none"],"marker":{"color":"rgba(31,119,180,1)","line":{"color":"rgba(31,119,180,1)"}},"error_y":{"color":"rgba(31,119,180,1)"},"error_x":{"color":"rgba(31,119,180,1)"},"frame":null},{"colorbar":{"title":"z<br />z<br />z<br />z<br />z<br />z<br />z","ticklen":2},"colorscale":[[0,"lightgrey"],[1,"lightgrey"]],"showscale":false,"z":[[0,0],[0,0]],"type":"surface","x":[0,8],"y":[0,8],"opacity":0.10000000000000001,"name":"M₁ Subspace","frame":null},{"x":[0,4],"y":[0,5],"z":[0,3],"type":"scatter3d","mode":"lines+markers","line":{"color":"blue","width":10},"marker":{"color":"blue","size":5,"line":{"color":"rgba(44,160,44,1)"}},"name":"y (Observed)","error_y":{"color":"rgba(44,160,44,1)"},"error_x":{"color":"rgba(44,160,44,1)"},"frame":null},{"x":[0,4],"y":[0,0],"z":[0,0],"type":"scatter3d","mode":"lines+markers","line":{"color":"red","width":10},"marker":{"color":"red","size":5,"line":{"color":"rgba(214,39,40,1)"}},"name":"ŷ₀","error_y":{"color":"rgba(214,39,40,1)"},"error_x":{"color":"rgba(214,39,40,1)"},"frame":null},{"x":[0,4],"y":[0,5],"z":[0,0],"type":"scatter3d","mode":"lines+markers","line":{"color":"darkgreen","width":10},"marker":{"color":"darkgreen","size":5,"line":{"color":"rgba(148,103,189,1)"}},"name":"ŷ₁","error_y":{"color":"rgba(148,103,189,1)"},"error_x":{"color":"rgba(148,103,189,1)"},"frame":null},{"x":[4,4],"y":[0,5],"z":[0,3],"type":"scatter3d","mode":"lines","line":{"color":"red","width":5,"dash":"solid"},"name":"e₀ (RSS₀)","marker":{"color":"rgba(140,86,75,1)","line":{"color":"rgba(140,86,75,1)"}},"error_y":{"color":"rgba(140,86,75,1)"},"error_x":{"color":"rgba(140,86,75,1)"},"frame":null},{"x":[4,4],"y":[5,5],"z":[0,3],"type":"scatter3d","mode":"lines","line":{"color":"darkgreen","width":5,"dash":"solid"},"name":"e₁ (RSS₁)","marker":{"color":"rgba(227,119,194,1)","line":{"color":"rgba(227,119,194,1)"}},"error_y":{"color":"rgba(227,119,194,1)"},"error_x":{"color":"rgba(227,119,194,1)"},"frame":null},{"x":[4,4],"y":[0,5],"z":[0,0],"type":"scatter3d","mode":"lines","line":{"color":"orange","width":6,"dash":"dot"},"name":"Diff","marker":{"color":"rgba(127,127,127,1)","line":{"color":"rgba(127,127,127,1)"}},"error_y":{"color":"rgba(127,127,127,1)"},"error_x":{"color":"rgba(127,127,127,1)"},"frame":null},{"type":"scatter3d","mode":"text","x":[4,4,4],"y":[5,0,5],"z":[3,0,0],"text":["y","ŷ₀","ŷ₁"],"textfont":{"size":18,"color":"black","family":"Arial Black"},"textposition":["top center","top center","bottom center"],"showlegend":false,"marker":{"color":"rgba(188,189,34,1)","line":{"color":"rgba(188,189,34,1)"}},"error_y":{"color":"rgba(188,189,34,1)"},"error_x":{"color":"rgba(188,189,34,1)"},"line":{"color":"rgba(188,189,34,1)"},"frame":null},{"type":"scatter3d","mode":"text","x":[4,4],"y":[2.5,5],"z":[1.5,1.5],"text":["e₀","e₁"],"textfont":{"size":14,"color":"darkblue"},"textposition":["middle right","middle right"],"showlegend":false,"marker":{"color":"rgba(23,190,207,1)","line":{"color":"rgba(23,190,207,1)"}},"error_y":{"color":"rgba(23,190,207,1)"},"error_x":{"color":"rgba(23,190,207,1)"},"line":{"color":"rgba(23,190,207,1)"},"frame":null}],"highlight":{"on":"plotly_click","persistent":false,"dynamic":false,"selectize":false,"opacityDim":0.20000000000000001,"selected":{"opacity":1},"debounce":0},"shinyEvents":["plotly_hover","plotly_click","plotly_selected","plotly_relayout","plotly_brushed","plotly_brushing","plotly_clickannotation","plotly_doubleclick","plotly_deselect","plotly_afterplot","plotly_sunburstclick"],"base_url":"https://plot.ly"},"evals":[],"jsHooks":[]}</script>
```


Geometric Interpretation: Projection onto Axis (M0) vs Plane (M1)
:::
:::


The geometric perspective is not merely for intuition, but as the most robust framework for mastering linear models. This approach offers three distinct advantages:

-   **Statistical Clarity:** Geometry provides the most natural path to understanding the properties of estimators. By viewing least square estimation as an orthogonal projection, the decomposition of sums of squares into independent components becomes visually obvious, demystifying how degrees of freedom relate to subspace dimensions rather than abstract algebraic constants. The sampling distribution of the sum squares become straightforward.
-   **Computational Stability:** A geometric understanding is essential for implementing efficient and numerically stable algorithms. While the algebraic "Normal Equations" ($(X'X)^{-1}X'y$) are theoretically valid, they are often computationally hazardous. The geometric approach leads directly to superior methods—such as QR and Singular Value Decompositions—that are the backbone of modern statistical software.
-   **Generalizability:** The principles of projection and orthogonality extend far beyond the Gaussian linear model. These geometric insights provide the foundational intuition needed for tackling non-Gaussian optimization problems, including Generalized Linear Models (GLMs) and convex optimization, where solutions can often be viewed as projections onto convex sets.
