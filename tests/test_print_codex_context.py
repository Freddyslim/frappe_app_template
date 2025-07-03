from scripts.new_frappe_app_folder import parse_args


def test_parse_args():
    args = parse_args(['demoapp'])
    assert args.app_name == 'demoapp'
