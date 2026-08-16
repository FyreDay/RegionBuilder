from enum import Enum

from .regions import Regions

class EntranceTypeEnum(Enum):
    def __init__(self, value: str, exiting_region: RegionTypeEnum, entering_region: RegionTypeEnum, direction_type: DirectionType, transition_type: TransitionType, rule):
        # self._value_ must be set to the first element to support lookup by value
        self._value_ = value
        self.exiting_screen = exiting_region
        self.entering_screen = entering_region
        self.entrance_group = transition_type
        self.rule = rule


class Entrances(EntranceTypeEnum):    TEST_REGION_1_TO_IDK_WHAT = ("Test Region 1_To_idk what", Regions.TEST_REGION_1, Regions.IDK_WHAT, 0, True_())
    IDK_WHAT_TO_TEST_REGION_3 = ("idk what_To_Test Region 3", Regions.IDK_WHAT, Regions.TEST_REGION_3, 0, True_())
    IDK_WHAT_TO_TEST_REGION_3_BACK = ("idk what_To_Test Region 3 Backwards", Regions.TEST_REGION_3, Regions.IDK_WHAT, 0, True_())
    TEST_REGION_3_TO_TEST_REGION_1 = ("Test Region 3_To_Test Region 1", Regions.TEST_REGION_3, Regions.TEST_REGION_1, 0, True_())
