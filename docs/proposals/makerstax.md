# MakerStax: stacked MakerRail hosts

**Status:** Discussion draft / potential specification, not an adopted standard.
**Captured:** September 20, 2026.
**Origin:** Cyberdeck design discussion in the deck_riptide project.

This proposal captures the goals, alternatives, and recommendations from that
discussion. Recommendations are not approved dimensions or validated joints.
No rail geometry, panel interface, or manufacturing files change with this
draft.

## Intent

Extend MakerRail from a flat panel host into a stack of reusable panel-hosting
layers. Each layer should remain useful on its own or within a stack.

The user's requested capabilities are:

- Continue using existing flat MakerPanels.
- Add nominal 1U depth between rail layers.
- Connect layers using columns that can engage slots, similar to T-slot mounts.
- Allow the bottom layer to be glued or screwed to a supporting surface.
- Preserve each layer's ability to act as a MakerRail host.

The name **MakerStax** describes this proposed extension. Electrical buses,
case-specific dimensions, and a new panel-hole standard are outside this draft.

## Conceptual arrangement

The proposed assembly is a stack of complete rail frames, separated by column
segments. Columns sit outside the panel footprint. An internal frame may carry
electronics trays or flat panels; the highest frame may carry exposed controls.

```text
       column                       column
          |   flat MakerPanels         |
          +--[ MakerRail frame ]-------+  Layer 2
          |                            |
          |     electronics bay        |
          |                            |
          +--[ MakerRail frame ]-------+  Layer 1
          |                            |
          +--[ MakerRail frame ]-------+  Layer 0
       [foot]                        [foot]
       --------- case / baseplate ---------
```

This is a conceptual side view, not a dimensioned joint drawing. Side receivers
and fasteners are omitted for clarity. Space outside the panel footprint is a
real packaging cost and must be included in the enclosure envelope.

## Existing interface baseline

The [MakerPanel specification](../specification.md) remains the panel reference.
The current implementation is in `makerpanel/common.scad` and
`makerpanel/rails.scad`; `makerpanel/rails_laser.scad` reuses its 2D profile.

Implementation observations at capture time:

- `U` is 44.45 mm and `HP` is 5.08 mm.
- The default rail is an 11 mm wide strip, 3 mm thick.
- Slots are rounded, elongated through-openings in that strip, not continuous
  undercut channels like an aluminum extrusion.
- The implemented slot opening height is 6.9 mm.
- Slot length starts from `5.75 * HP` and expands to fit the selected rail
  length; the nominal support width is 3 mm.
- Optional end mounting holes are 3.5 mm diameter.

Some published slot dimensions and hardware descriptions differ from the code.
Even the slot-width comment says 29.06 mm while `5.75 * 5.08` is 29.21 mm.
Reconcile the intended baseline before dimensioning a production connector.
Do not infer a fixed 1U slot repeat from the current slot-distribution
algorithm.

A nut's external fit and its thread size are separate requirements. Select and
test a matching screw/nut pair rather than treating M3, M5, and M6 as
interchangeable. Retain space behind a through-slot for the chosen hardware.

## Proposed architecture

### 1. Rail frame

Each frame provides the same panel-facing rail interface as a standalone host.
Structural carriers below and outboard of the rails provide column connections.
The frame, not removable panels, transfers loads between columns.

Candidate construction: existing metal rail strips fastened to printed corner
carriers or a structural perimeter carrier. Metal reinforcement or formed
sections remain options; the material system is not yet selected.

### 2. Column segment

A column spans one interval between adjacent frames. Keyed end shoes locate it
against matching receivers; a bearing shoulder establishes the stack height.
Independent segments avoid a single long tie bolt through the whole stack.

Suggested connection features:

- A tongue, saddle, or equivalent key resists rotation and lateral movement.
- A positive bearing surface carries compression into the structural carrier.
- A retained fastener carries separation loads and locks the connection.
- Side access permits tightening without removing a panel directly above it.
- A captive backing plate or suitable T-nut engages the receiver opening.
- Sufficient engagement and clearance allow assembly without forced flexing.

Use two separated fasteners or a fastener plus a positive locating feature
where necessary to resist moments. Do not assume one friction-clamped screw or
a printed snap tab alone will withstand transport loads.

For a flat slotted receiver, the retaining plate needs access and clearance
behind the slot. A true sliding T-head channel would require an additional
backing structure and an insertion path. Neither feature exists automatically
in the current flat rail profile.

### 3. Base foot

Use the same frame/column connection with interchangeable mounting feet:

- **Screw-down foot:** flange with accessible fastening locations and a load
  spreader or backing plate appropriate to the supporting surface.
- **Bonded foot:** broad bonding pad, with the stack detachable from the foot.

Bond design depends on substrate, adhesive, preparation, peel loading, and
temperature. Ordinary epoxy is not a dependable default for polypropylene.
Qualify a polyolefin-compatible bonding system if mounting to such a case.
Through-fastening a weatherproof shell also needs a sealing strategy.

## Column attachment alternatives

| Approach | Benefit | Tradeoff |
| --- | --- | --- |
| Existing top slots | Simple retrofit | Consumes panel mounting area |
| End-hole corner shoes | Small first prototype | Fixed post locations |
| Separate side receivers | Preserves top slots | Adds width and parts |

**Recommended first prototype:** two identical frames and four outboard corner
columns, with keyed shoes and side-accessible fasteners. Corner carriers should
support the rail ends without obstructing panel hardware. Test their load path
before relying on the existing end holes as structural stack connections.

If movable columns are valuable, extend the corner receiver concept along the
perimeter. Keep the column interface separate from the panel interface.

Using the existing top slots remains a valid reduced-parts option, but cannot
preserve unrestricted panel use at the occupied mounting locations. A wider
perimeter or dedicated attachment zone is the cost of avoiding that conflict.

## What does 1U depth mean?

This decision remains open. Two useful definitions are:

1. **Layer pitch:** 44.45 mm between corresponding panel seating planes.
2. **Clear equipment depth:** 44.45 mm of unobstructed space for equipment.

The recommendation from the discussion is to use layer pitch as the repeatable
stack datum. Clear depth then depends on the parts installed in each bay.
If 44.45 mm clear depth is required, the pitch must increase accordingly.

For two facing seating planes separated by pitch `P`, let `a` be the lower
assembly's intrusion upward and `b` the upper assembly's intrusion downward.
Where those footprints overlap, available clearance is `P - a - b`.
Include panels, rails, nuts, screw ends, controls, connectors, and cable bends
in these intrusion envelopes, with an additional assembly margin.

Column cut length is derived from the seating-plane pitch and receiver offsets;
it is not automatically 44.45 mm. Existing panel assemblies with up to 60 mm
depth will not necessarily fit a 1U bay even though their mounting pattern fits.

## Preserving every layer as a MakerRail host

The proposed compatibility contract is:

- Keep the panel seating plane, rail spacing, and panel-facing slots unchanged.
- Preserve insertion, rotation, and clamping clearance for panel hardware.
- Keep column feet and their screw heads outside the panel mounting envelope.
- Permit the same frame to be used at the bottom, middle, or top of a stack.
- Transfer stack loads through carriers and columns, not removable panels.
- Make occupied-slot limitations explicit for any retrofit adapter.

Compatibility does not imply unlimited equipment clearance or independent
removal of every panel. Lower panels may require lifting the tier above.
Side-accessible column joints help serviceability but do not make a middle
layer removable while it is still supporting the upper stack.

## Stiffness, service, and packaging

Four columns with weak joints can rack sideways. Prototype a removable shear
panel or diagonal bracing in two perpendicular vertical planes, or demonstrate
equivalent stiffness from moment-resisting joints. Do not assume electrical
panels provide bracing unless their attachments are designed for it.

Reserve cable paths, connector access, strain relief, ventilation, and tool
clearance. Allow supported removal of an upper module without straining cables.
Heavier equipment should load the structural frame rather than a thin panel.
More columns or intermediate supports may be needed for wide spans.

## Open decisions

- Layer pitch versus guaranteed clear equipment depth.
- Frame footprint and acceptable outboard column allowance.
- Fixed corner posts versus repositionable perimeter posts.
- Receiver shape, insertion direction, and retention hardware.
- Materials, tolerances, reinforcement, and assembly preload.
- Equipment mass, stack count, allowable deflection, and transport loads.
- Bracing arrangement and required panel/service access.
- Base substrate and fastening or bonding method.

No joint dimensions, load ratings, or universal compatibility claims are
established by this draft.

## Prototype and validation plan

1. Reconcile the rail baseline and select actual matching mounting hardware.
2. Model a single receiver and column shoe, including nut and tool envelopes.
3. Make a fit coupon before producing full frames or columns.
4. Build two identical frames with four columns and representative panels.
5. Confirm existing panel mounting and nut access on both layers.
6. Measure seating-plane pitch and loaded equipment clearances.
7. Test compression, separation, lateral racking, and torsion for intended
  loads.
8. Check printed-part creep, insert retention, and repeated assembly wear.
9. Test feet and substrate attachment separately, including peel where bonded.
10. Verify service access, cabling, and enclosure fit before adding more tiers.

Future OpenSCAD work should reuse the canonical rail profile rather than
duplicate it. Validate and render each geometry change; physical joint tests
are still required. No prototype, structural test, or geometry render was
performed as part of this documentation capture.