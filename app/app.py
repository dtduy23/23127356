from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def read_root():
    return {"message": "Hello from Jenkins CI/CD!"}

@app.get("/health")
def health():
    return {"status": "healthy"}

@app.get("/test")
def test():
    return {"result": "CI/CD is working!"}

@app.post("/post")
def post():
    return{"result:": "test posting"}

@app.post("/post")
def post2():
    return {"result:": "test 2"}