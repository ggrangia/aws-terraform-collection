import { App } from "cdktf";
import { MyStack } from "./mystack";

const app = new App();
new MyStack(app, "parallel-lambda-step-function");
app.synth();
