from index import getTagValue, lambda_handler, associateAttachment, propagateAttachment


class TestTgwPropagation:
    # Setup a failing test
    def test_lambda_handler(self):
        assert False

    def test_getTagValue(self):
        tags = [
            {"Key": "test1", "Value": "test"},
            {"Key": "Type", "Value": "attachment_type"},
            {"Key": "Name", "Value": "Global"},
        ]
        name = getTagValue(tags, "Name")
        typeTag = getTagValue(tags, "Type")

        assert name == "Global"
        assert typeTag == "attachment_type"

    def test_propagateAttachment(self):
        assert False

    def test_associateAttachment(self):
        assert False
