from metaflow import FlowSpec, step, resources, S3
import pandas as pd


class MyFlow(FlowSpec):

    # memory in MiB (1GB = 1024MiB)
    # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html
    @resources(memory=2048, cpu=1)
    @step
    def start(self):
        self.my_var = "hello world"
        df = pd.DataFrame(columns=["a", "b"])
        for i in range(10000):
            df = pd.concat(
                [pd.DataFrame([[1, 2]], columns=df.columns), df], ignore_index=True
            )

        self.next(self.a)

    @step
    def a(self):
        print(f"the data artifact is: {self.my_var}")
        self.next(self.branch_a, self.branch_b)

    @step
    def branch_a(self):
        print(f"Branching a: {self.my_var}")
        self.next(self.aggregator)

    @step
    def branch_b(self):
        print(f"Branching b: {self.my_var}")
        self.next(self.aggregator)

    @step
    def aggregator(self, inputs):
        self.my_var = inputs.branch_a.my_var + inputs.branch_b.my_var
        print(f"Aggregating.. {self.my_var}")
        self.next(self.end)

    @step
    def end(self):
        print(f"the data artifact is still: {self.my_var}")
        pass


if __name__ == "__main__":
    MyFlow()
