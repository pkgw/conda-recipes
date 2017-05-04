# Test C++/Python mapping a bit.

import numpy as np
from numpy.testing import assert_array_equal
import casac

qa = casac.casac.quanta()

# exercises conversions of: variant&, string& => record*
x = qa.quantity(1, b'm')
assert isinstance(list(x.keys())[0], str) # this should hold for either Python 2 or 3
assert isinstance(x['unit'], str) # ditto
assert isinstance(x['value'], float) # ditto

x = qa.quantity(1, u'm')
assert isinstance(list(x.keys())[0], str) # this should hold for either Python 2 or 3
assert isinstance(x['unit'], str) # ditto
assert isinstance(x['value'], float) # ditto

x = qa.quantity([1, 2], 'm')
assert isinstance(x['value'], np.ndarray)
assert_array_equal(x['value'], [1., 2.])

x = qa.quantity([1., 2., 3.], 'm')
assert isinstance(x['value'], np.ndarray)
assert_array_equal(x['value'], [1., 2., 3.])

x = qa.quantity(np.array([1., 2., 3.]), 'm')
assert isinstance(x['value'], np.ndarray)
assert_array_equal(x['value'], [1., 2., 3.])

try:
    qa.quantity(b'hello', 'm')
except RuntimeError:
    pass
else:
    assert False, 'call should have failed'

try:
    qa.quantity(u'hello', 'm')
except RuntimeError:
    pass
else:
    assert False, 'call should have failed'

# exercises: variant& => vector<double>
z = qa.getvalue(x)
assert isinstance(z, np.ndarray)
assert_array_equal(z, [1., 2., 3.])

# exercises: variant& => string
u = qa.getunit(x)
assert isinstance(u, str) # what we want on both Py 2 and Py 3
assert u == 'm'

# exercises: string&, variant& => bool
f = qa.define('myunit', '1 Hz')
assert isinstance(f, bool)
assert f

# exercises: variant&, int, vector<string>&, bool => vector<string>
r = qa.angle('1 deg', 3, '', False)
assert isinstance(r, list)
assert len(r) == 1
assert isinstance(r[0], str)
assert r[0] == '+001.00.'
