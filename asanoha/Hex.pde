import java.util.ArrayList;
import java.util.Arrays;

Hex[] DIRECTIONS = {
    new Hex(1, 0, -1),
    new Hex(1, -1, 0),
    new Hex(0, -1, 1),
    new Hex(-1, 0, 1),
    new Hex(-1, 1, 0),
    new Hex(0, 1, -1)
};

Orientation POINTY = new Orientation(sqrt(3), sqrt(3)/2, 0.0, 3.0/2, sqrt(3)/3, -1.0/3, 0, 2.0/3, 0.5);
Orientation FLAT = new Orientation(3.0/2, 0, sqrt(3)/2, sqrt(3), 2.0/3, 0, -1.0/3, sqrt(3)/3, 0);

class Hex {

    public final int q;
    public final int r;
    public final int s;

    public Hex(int q, int r, int s) {
        this.q = q;
        this.r = r;
        this.s = s;
        if (q + r + s != 0)
            throw new IllegalArgumentException("q + r + s must be 0");
    }

    public boolean equals(Hex other) {
        return (q == other.q && r == other.r && s == other.s);
    }

    public Hex add(Hex other) { 
        return new Hex(q + other.q, r + other.r, s + other.s);
    }

    public Hex sub(Hex other) {
        return new Hex(q - other.q, r - other.r, s - other.s);
    }

    public Hex scale(int k) {
        return new Hex(q * k, r * k, s * k);
    }

    private int length(Hex other) {
        return int((abs(other.q) + abs(other.r) + abs(other.s)) / 2);
    }

    public int distance(Hex other) {
        return length(sub(other));
    }

    public Hex rotateLeft() {
        return new Hex(-s, -q, -r);
    }

    public Hex rotateRight() {
        return new Hex(-r, -s, -q);
    }

    private Hex direction(int direction) {
        return DIRECTIONS[direction % 6];
    }

    public Hex neighbor(int direction) {
        return add(direction(direction));
    }
}

class FractionalHex {
    public final float q;
    public final float r;
    public final float s;

    public FractionalHex(float q, float r, float s) {
        this.q = q;
        this.r = r;
        this.s = s;
        if (round(q + r + s) != 0) throw new IllegalArgumentException("q + r + s must be 0");
    }

    public Hex hexRound() {
        int qi = (int)(round(q));
        int ri = (int)(round(r));
        int si = (int)(round(s));
        float q_diff = abs(qi - q);
        float r_diff = abs(ri - r);
        float s_diff = abs(si - s);
        if (q_diff > r_diff && q_diff > s_diff)
            qi = -ri - si;
        else if (r_diff > s_diff)
            ri = -qi - si;
        else
            si = -qi - ri;
        return new Hex(qi, ri, si);
    }

    public FractionalHex hexLerp(FractionalHex b, float t) {
        return new FractionalHex(q * (1.0 - t) + b.q * t, r * (1.0 - t) + b.r * t, s * (1.0 - t) + b.s * t);
    }

    public ArrayList<Hex> hexLineDraw(Hex a, Hex b) {
        int N = a.distance(b);
        FractionalHex a_nudge = new FractionalHex(a.q + 1e-06, a.r + 1e-06, a.s - 2e-06);
        FractionalHex b_nudge = new FractionalHex(b.q + 1e-06, b.r + 1e-06, b.s - 2e-06);
        ArrayList<Hex> results = new ArrayList<Hex>(){{}};
        float step = 1.0 / max(N, 1);
        for (int i = 0; i <= N; i++) {
            results.add(a_nudge.hexLerp(b_nudge, step * i).hexRound());
        }
        return results;
    }
}

class Orientation {
    public final float f0, f1, f2, f3;
    public final float b0, b1, b2, b3;
    public final float start_angle;

    public Orientation(float f0, float f1, float f2, float f3, 
                       float b0, float b1, float b2, float b3,
                       float start_angle) {
        this.f0 = f0;
        this.f1 = f1;
        this.f2 = f2;
        this.f3 = f3;
        this.b0 = b0;
        this.b1 = b1;
        this.b2 = b2;
        this.b3 = b3;
        this.start_angle = start_angle;
    }
}

class Layout {
    public final Orientation M;
    public final PVector size;
    public final PVector origin;

    public Layout(Orientation orientation, PVector size, PVector origin) {
        this.M = orientation;
        this.size = size;
        this.origin = origin;
    }

    public PVector hexToPixel(Hex hex) {
        float x = (M.f0 * hex.q + M.f1 * hex.r) * size.x;
        float y = (M.f2 * hex.q + M.f3 * hex.r) * size.y;
        return PVector.add(new PVector(x,y), origin);
    }

    public FractionalHex pixelToHex(PVector pixel) {
        PVector pt = new PVector((pixel.x - origin.x) / size.x, (pixel.y - origin.y) / size.y);
        float q = (float)(M.b0 * pt.x + M.b1 * pt.y);
        float r = (float)(M.b2 * pt.x + M.b3 * pt.y);
        return new FractionalHex(q, r, -q - r);
    }

    public PVector hexCornerOffset(int corner) {
        float angle = 2.0 * PI * (M.start_angle - corner) / 6.0;
        return new PVector(size.x * cos(angle), size.y * sin(angle));
    }

    public ArrayList<PVector> polygonCorners(Hex hex) {
        ArrayList<PVector> corners = new ArrayList<PVector>();
        PVector center = hexToPixel(hex);
        for (int i = 0; i < 6; i++) {
            PVector offset = hexCornerOffset(i);
            corners.add(PVector.add(center, offset));
        }
        return corners;
    }
}
