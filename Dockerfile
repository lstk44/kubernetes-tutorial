# ==============================================================================
# STEP 1: BASE IMAGE SELECTION
# ==============================================================================
# We use 'python:3.11-slim' as our foundation. 
# - '3.11': A stable, modern version of Python.
# - 'slim': A stripped-down version of Debian Linux that excludes bloatware 
#           (like compilers and documentation) to keep the container image 
#           file size small and secure against security vulnerabilities.
FROM python:3.11-slim

# ==============================================================================
# STEP 2: CONTAINER WORKDIR SETUP
# ==============================================================================
# WORKDIR acts like 'cd' inside the container. It creates the '/app' directory 
# if it doesn't already exist and makes it the default folder where all 
# subsequent commands (COPY, RUN, CMD) will be executed.
WORKDIR /app

# ==============================================================================
# STEP 3: INSTALLING THE 'UV' PACKAGE MANAGER
# ==============================================================================
# Instead of installing uv via curl inside the container (which adds layers and 
# slows down builds), we copy the pre-built, lightning-fast 'uv' and 'uvx' 
# binaries directly from Astral's official container registry image.
# This is a modern best practice for clean and fast multi-stage copying.
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

# ==============================================================================
# STEP 4: DEPENDENCY LAYER CACHING (THE SECRET TO FAST BUILDS)
# ==============================================================================
# Docker builds images in "layers" and caches them. If a file doesn't change, 
# Docker reuses the cached layer instead of re-running the command.
# 
# By copying ONLY 'pyproject.toml' and 'uv.lock' *before* copying our source code, 
# Docker will cache the heavy package installation step. If you change a python 
# script later, Docker won't waste time re-downloading external dependencies!
COPY pyproject.toml uv.lock ./

# ==============================================================================
# STEP 5: SYNCING CORE DEPENDENCIES (CACHED LAYER)
# ==============================================================================
# We run 'uv sync' to build the project's internal virtual environment (.venv) 
# and install core dependencies.
# Flags explained:
# - --frozen: Tells uv to strictly use exact versions locked in 'uv.lock'.
# - --no-dev: Skips development-only tools to keep the production image lean.
# - --no-install-project: Installs *only* third-party dependencies for now, 
#                         since we haven't copied our source code into the image yet.
RUN uv sync --frozen --no-dev --no-install-project

# ==============================================================================
# STEP 6: COPYING SOURCE CODE
# ==============================================================================
# Now that dependencies are installed and cached, we copy the rest of our 
# project files—including our application source files—into the container's '/app' directory.
COPY . /app

# ==============================================================================
# STEP 7: REGISTERING THE LOCAL PACKAGE INTO THE VENV
# ==============================================================================
# Running 'uv sync' a second time now includes our newly copied local source code 
# package into the virtual environment, ensuring imports resolve properly.
RUN uv sync --frozen --no-dev

# ==============================================================================
# STEP 8: UPDATING THE SYSTEM PATH
# ==============================================================================
# We prepend the virtual environment's bin folder to the container's PATH environment 
# variable. This ensures that any subsequent 'python' command automatically points 
# to the virtual environment's Python interpreter rather than the system default.
ENV PATH="/app/.venv/bin:$PATH"

# ==============================================================================
# STEP 9: CONTAINER STARTUP COMMAND
# ==============================================================================
# CMD specifies the default command executed when you run 'docker run'.
# We use Python's module execution flag (-m) to run 'kubernetes_tutorial.main'. 
# This prevents relative import errors and treats the code as an installed package.
CMD ["python", "-m", "kubernetes_tutorial.main"]
