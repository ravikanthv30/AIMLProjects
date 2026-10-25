#!/bin/bash
# ==============================================================================
# SuperKart Deployment - End-to-End Codespaces Build & Run Script
# ==============================================================================

# 1. Go back to the root workspace
cd /workspaces/superkart-deployment

# 2. Stop and remove any existing containers (or background processes on ports 7860/8501)
docker rm -f backend frontend || true
pkill -f "python app.py" || true
pkill -f "streamlit run app.py" || true

# 3. Build Backend and Frontend Docker images from their respective folders
docker build -t superkart-backend ./backend_files
docker build -t superkart-frontend ./frontend_files

# 4. Run Backend with --network host and 1 worker (-w 1) plus --preload so the model loads once
docker run -d --name backend --network host superkart-backend \
    gunicorn -w 1 --preload --timeout 120 -b 0.0.0.0:7860 app:superkart_api

# 5. Wait 3 seconds and test the backend locally inside Codespaces to verify it responds
sleep 3
curl http://localhost:7860/
echo ""

# 6. Run Frontend with --network host pointing directly to localhost:7860
docker run -d --name frontend --network host \
    -e BACKEND_URL="http://localhost:7860" superkart-frontend

# 7. Verify both containers are up and running
docker ps


# ==============================================================================
# OPTIONAL FALLBACK: Run Directly via Python (Only if NOT running Docker above)
# ==============================================================================
# cd /workspaces/superkart-deployment
# docker rm -f backend frontend || true
# pip install -r backend_files/requirements.txt streamlit
# cd backend_files && python app.py &
# cd ../frontend_files && streamlit run app.py --server.port=8501 --server.address=0.0.0.0 &