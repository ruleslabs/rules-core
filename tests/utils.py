from itertools import chain

def dict_to_tuple(data):
  return tuple(dict_to_tuple(d) if type(d) is dict else d for d in data.values())

def to_flat_tuple(data):
  items = []
  values = data.values() if type(data) is dict else data
  for d in values:
    if type(d) is dict:
      items.extend([*to_flat_tuple(d)])
    elif type(d) is tuple:
      items.extend([*to_flat_tuple(d)])
    else:
      items.append(d)

  return tuple(items)

def update_dict(dict, **new):
  return (lambda d: d.update(**new) or d)(dict)
